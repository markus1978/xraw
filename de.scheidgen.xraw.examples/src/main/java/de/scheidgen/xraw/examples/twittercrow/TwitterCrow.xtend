package de.scheidgen.xraw.examples.twittercrow

import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterUser
import de.scheidgen.xraw.json.JSON
import de.scheidgen.xraw.script.XRawScript
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths
import java.util.List
import org.json.JSONObject

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*

/** 
 * Identifies potential friends, based on keywords, languages, follower/friend ratio, and social authority (i.e. retweet/favourite ratios). 
 */
class TwitterCrow {
	val keywords = #["game studio"]
	
	def boolean matches(TwitterUser user) {
		keywords.exists[user.description.contains(it)] 
	}
	
	def boolean hasGoodStats(TwitterUser user) {
		(user.friendsCount*1.10 > user.followersCount) && user.statusesCount > 100 && user.favouritesCount > 30
	}
	
	def <E> void forEach(Iterable<E> source, (E)=>boolean predicate) {
		var continue = true
		var it = source.iterator
		while (continue && it.hasNext) {
			continue = predicate.apply(it.next)
		}
	}
	
	def void run() {
		
		val twitter = XRawScript::get("data/store", "markus", Twitter)		
		val me = twitter.users.show.screenName("mscheidgen").xCheck.xResult
		
		val users = new TwitterCrowPotentialFriends
		users.seeds += me
		users.file = "data/potentialFriends2.json"
		
		 Twitter::safeBlockingCursor(twitter.friends.list.screenName(me.screenName).count(200)) [
		 	val nextBatch = newArrayList
		 	nextBatch.addAll(it.users)
		 	nextBatch.sort[a,b|return Integer.compare(b.followersCount,a.followersCount)]
		 	
			nextBatch.forEach[user|
				if (user.matches) {
					users.seeds += user
					println("---")
					print('''user «user.screenName» with «user.followersCount» as a source of potential friends: ''')
					val result = Twitter::safeBlockingCursor(twitter.followers.id.screenName(user.screenName)) [						
						print(it.ids.size + "=>[")
						Twitter::safeBlockingForEach(it.ids.split(100), [twitter.users.lookup.userId(it.toList)], [
							val next = it.xResult
							print(next.size)
							next.forEach[
								if (it.matches && it.hasGoodStats)
								users.users += it
							]
						])
										
						println("]")
						println("> could extract " + users.users.size + " so far")
				
						users.save	
					].report				
					return result					
				} else {
					return true
				}			
			]
		].report
		
		println("===")
		println("Could extract " + users.users.size + " users based on " + me.screenName)
		
		users.save		
	}
	
	def report(TwitterResponse response) {
		if (response.rateLimitExeeded) {
			println("Rate limit exeeded")
		} else if (!response.successful) {
			println("Response not successful")
		}
		return response.successful
	}
	
	public static def void main(String[] args) {
		val crow = new TwitterCrow()
		crow.run
	}
}

@JSON(mutable=true) class TwitterCrowPotentialFriends {
	String file
	List<TwitterUser> seeds	
	List<TwitterUser> users
	
	static def load(String file) {
		val result = new TwitterCrowPotentialFriends(new JSONObject(Files.readAllLines(Paths.get(file), StandardCharsets.UTF_8).join("\n")))
		result.file = file
		return result
	}
	
	def save() {
		Files.write(Paths.get(file), xJson.toString(4).getBytes());
	}
}