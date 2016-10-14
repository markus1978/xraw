package de.scheidgen.xraw.examples.twittercrow

import com.github.scribejava.apis.TwitterApi
import com.mongodb.BasicDBObject
import com.mongodb.MongoException
import de.scheidgen.xraw.annotations.Resource
import de.scheidgen.xraw.annotations.WithConverter
import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.response.TwitterConnections
import de.scheidgen.xraw.apis.twitter.response.TwitterUser
import de.scheidgen.xraw.http.ScribeOAuth1Service
import de.scheidgen.xraw.json.DateConverter
import de.scheidgen.xraw.mongodb.Collection
import de.scheidgen.xraw.mongodb.MongoDB
import de.scheidgen.xraw.script.XRawScript
import de.scheidgen.xraw.server.JsonOrgObject
import java.util.Date
import java.util.List

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*
import de.scheidgen.xraw.apis.twitter.TwitterUtil

/** 
 * Identifies potential friends, based on keywords, languages, follower/friend ratio, and social authority (i.e. retweet/favourite ratios). 
 */
class TwitterCrow {
	val twitter = XRawScript::get("data/store", "markus", Twitter) [new ScribeOAuth1Service(TwitterApi.instance, it)]		
	val keywords = #["game studio"]
	
	private def boolean matches(TwitterUser user) {
		keywords.exists[user.description.contains(it)] 
	}
	
	private def boolean hasGoodStats(TwitterUser user) {
		(user.friendsCount*1.10 > user.followersCount) && user.statusesCount > 100 && user.favouritesCount > 30
	}
	
	private def <E> void forEach(Iterable<E> source, (E)=>boolean predicate) {
		var continue = true
		var it = source.iterator
		while (continue && it.hasNext) {
			continue = predicate.apply(it.next)
		}
	}
	
	def void collectPotientialFriendsFromFriendsFollowers(TwitterUser source, (TwitterUser,TwitterUser)=>Void add) {		
		TwitterUtil::safeBlockingCursor(twitter.friends.list.screenName(source.screenName).count(200)) [
		 	val nextBatch = newArrayList
		 	nextBatch.addAll(it.users)
		 	nextBatch.sort[a,b|return Integer.compare(b.followersCount,a.followersCount)]
		 	
			nextBatch.forEach[user|
				if (user.matches) {
					val result = TwitterUtil::safeBlockingCursor(twitter.followers.id.screenName(user.screenName)) [					
						TwitterUtil::safeBlockingForEach(it.ids.split(100), [twitter.users.lookup.userId(it.toList)], [
							val next = it.xResult
							next.forEach[
								if (it.matches && it.hasGoodStats) add.apply(user,it)
							]
						])
					].successful				
					return result					
				} else {
					return true
				}			
			]
		].successful
	}
	
	def void run() {
		val db = new TwitterCrowDB
		
		val primarySeed = twitter.users.show.screenName("mscheidgen").xCheck.xResult
		collectPotientialFriendsFromFriendsFollowers(primarySeed) [secondarySeed,user|
			println('''add «primarySeed.screenName»->«secondarySeed.screenName»<-«user.screenName»: «user.description»''')
			
			val result = new TwitterCrowPotentialFriend(new JsonOrgObject)
			result.screenName = user.screenName
			result.user = user
			result.foundTime = new Date
			result.foundWithSeeds += primarySeed
			result.foundWithSeeds += secondarySeed
			result.foundWithMethod = "friendsFollowers"
			result.foundWithKeywords.addAll(keywords)
			
			try {
				db.potentialFriends.add(result)
			} catch (MongoException e) {
				if (e.code != 11000) {	// ignore errors due to unique index violation
					throw e
				}
			}
			return null
		]
		
		MongoDB::client.close
	}
	
	public static def void main(String[] args) {
		val crow = new TwitterCrow()
		crow.run
	}
}

class AbstractRunner {
	def _(String key, Object value) {
		return new BasicDBObject(key, value)
	}
	
	protected val db = new TwitterCrowDB
	protected val twitter = XRawScript::get("data/store", "markus", Twitter) [new ScribeOAuth1Service(TwitterApi.instance, it)]
}

class PlanBefriend extends AbstractRunner{
	static val long A_DAY = 24 * 3600 * 1000
			
	
	var Date newActionTime = null
	var int actionsInOneDay = 0
	
	def run() {
		newActionTime = db.actions.query[it.find.sort("time"._(-1))]?.first?.time ?: new Date
		newActionTime = new Date(newActionTime.time + A_DAY)
		
		filter.map[db.potentialFriends.get(it)].forEach [potentialFriend |
			val actionKey = "befriend_" + potentialFriend.user.screenName
			if (db.actions.get(actionKey) == null) {
				val lastStatusUpdate = potentialFriend.user.status.createdAt
				val tmp = new Date(newActionTime.time);
				tmp.hours = lastStatusUpdate.hours
				val executionTime = if(tmp.time < newActionTime.time) new Date(tmp.time + 24 * 3600 * 1000) else tmp

				println('''add «actionKey» for «executionTime»''')
				val newAction = new Befriend(new JsonOrgObject) => [
					uuid = actionKey
					user = potentialFriend.user
					time = executionTime
					executed = false
				]
				db.actions.add(newAction)
				
				if (actionsInOneDay++ >= 5) {
					actionsInOneDay = 0
					newActionTime = new Date(newActionTime.time + A_DAY)
				}
			}
		]	
	}
	
	def filter() {
		val screenNames = db.potentialFriends.find(null,-1).map[it.screenName]
		val relationShips = twitter.friendships.lookup.screenName(screenNames.toList).xCheck.xResult
		val interstingScreenNames = relationShips.filter[
			!connections.contains(TwitterConnections.following) && 
			!connections.contains(TwitterConnections.following_requested) && 
			!connections.contains(TwitterConnections.followed_by)
		].map[it.screenName]
		
		return interstingScreenNames.toList
	}
	
	public static def void main(String[] args) {
		val instance = new PlanBefriend()
		instance.run()
	}
}

class ExecuteActions extends AbstractRunner {
	val db = new TwitterCrowDB
	val twitter = XRawScript::get("data/store", "markus", Twitter) [new ScribeOAuth1Service(TwitterApi.instance, it)]
	
	var boolean hasExecuted = false
	def boolean executeNext(Date now) {
		val lastActionsBeforeNow = db.actions.query[find("time"._("$lt"._(Long::toString(now.time)))).sort("time"._(-1))]
		hasExecuted = false	 
		lastActionsBeforeNow.forEachUntil[action|
			if (action.executed) return false	
			action.execute(twitter) 
			hasExecuted = true
			println(now + " executed " + action.uuid)
			
			Thread::sleep(3000)
			return true
		]
		
		return hasExecuted
	}	
	
	def run() {
		while (true) {
			val now = new Date
			executeNext(now)
			
			val nextActionFromNow = db.actions.query[it.find("time"._("$gt"._(Long::toString(now.time)))).sort("time"._(1))].first
			if (nextActionFromNow != null) {
				val waitFor = (nextActionFromNow.time.time - System::currentTimeMillis) + 5000
				println("-> wait, next action " + nextActionFromNow.uuid + " in " + (waitFor/1000) + " seconds at " + nextActionFromNow.time)	
				Thread::sleep(waitFor)
			} else {
				return
			}		
		} 
	}	
	
	public static def void main(String[] args) {
		val instance = new ExecuteActions()
		instance.run()
	}
}

class TwitterCrowDB extends MongoDB {
	new() { super("crow") }
	public val potentialFriends = new Collection(this, "potential_friends", TwitterCrowPotentialFriend).withUUID("screenName")
	public val actions = new Collection(this, "actions", Action).withUUID("uuid").withIndex("time", -1)
}

@Resource abstract class Action {
	String uuid
	@WithConverter(DateConverter) Date time
	boolean executed = false	
	
	abstract def void execute(Twitter twitter)	
}

@Resource class Befriend extends Action {
	TwitterUser	user
	
	override execute(Twitter twitter) {		
		executed = twitter.friendships.create.screenName(user.screenName).xResponse.successful
		xSave
	}
}

@Resource class TwitterCrowPotentialFriend {
	String screenName
	TwitterUser user
	
	@WithConverter(DateConverter) Date foundTime
	String foundWithMethod
	List<TwitterUser> foundWithSeeds
	List<String> foundWithKeywords
}