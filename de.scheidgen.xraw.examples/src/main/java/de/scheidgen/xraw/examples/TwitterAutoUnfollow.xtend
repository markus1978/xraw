package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.response.TwitterConnections
import de.scheidgen.xraw.http.ScribeOAuth1Service
import de.scheidgen.xraw.script.XRawScript
import org.scribe.builder.api.TwitterApi

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*

class TwitterAutoUnfollow {
	
	def static void main(String[] args) {		
		val screenName = "mscheidgen"
		val twitter = XRawScript::get("data/store.xmi", "markus", Twitter) [new ScribeOAuth1Service(TwitterApi, it)]
		
		println('''Looking for friends for "«screenName»"''')		
		val friends = newArrayList
		var response = TwitterUtil::safeCursor(twitter.friends.id.screenName(screenName).count(100)) [
			friends.addAll(it.ids)
		]
		println('''Found «friends.size» friends«IF response == null || response.rateLimitExeeded», before the rate limit was reached«ENDIF».''')
		
		println('''Retrieving friendships and looking for false friends''')
		val friendships = newArrayList
		response = TwitterUtil::safeForEach(friends.split(100),[twitter.friendships.lookup.userId(it)], [
			friendships.addAll(it.xResult)
		])
		if (!response.successful) {
			println(response.toString)
			return
		}
		
		val notFollowingFriendIds = friendships.filter[!it.connections.contains(TwitterConnections.followed_by)].map[id]
		println('''Found «notFollowingFriendIds.size» false friends«IF response==null || response.rateLimitExeeded», before the rate limit was reached«ENDIF». Start unfollowing now.''')
		
		response = TwitterUtil::safeForEach(notFollowingFriendIds.first(20), [twitter.friendships.destroy.userId(it)],[])
		println('''Sucessfully unfollowed xxx users«IF response != null», before the rate limit was reached«ENDIF».''')
	}
}