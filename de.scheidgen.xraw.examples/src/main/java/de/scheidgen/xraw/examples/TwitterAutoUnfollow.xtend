package de.scheidgen.xraw.examples

import de.scheidgen.xraw.XRawScript
import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.response.TwitterConnections
import java.util.ArrayList
import de.scheidgen.xraw.apis.twitter.response.TwitterFriendship

class TwitterAutoUnfollow {
	def static void main(String[] args) {
		val twitter = XRawScript::createWithStore("data/store.xmi").serviceWithLogin(Twitter, "markus")
		
		val myId = twitter.users.show.screenName("mscheidgen").xResult.id
		val friendIds = twitter.friends.id.userId(myId).count(5000).xResult.ids
		println(friendIds.size)
		
		val notFollowingFriends = new ArrayList<TwitterFriendship>()
		for (var i = 0; i < friendIds.size;) {
			val next100Ids = new ArrayList<String>();
			for (var ii = 0; ii < 100 && i < friendIds.size; ii++) {
				next100Ids.add(friendIds.get(i++))
			}
			val friendFriendships = twitter.friendships.lookup.userId(next100Ids).xResults
			notFollowingFriends.addAll(friendFriendships.filter[!it.connections.contains(TwitterConnections.followed_by)])		
		}		
		
		println("Found " + notFollowingFriends.size + "friend that are not following.")
		val numberToUnfollow = Math.min(10, notFollowingFriends.size)
		println("Try to unfollow the first " + numberToUnfollow + " user.")
		for (i: 0..<numberToUnfollow) {
			if (twitter.friendships.destroy.userId(notFollowingFriends.get(i).id).xResponse.successful) {
				println("Success: unfollowed " + notFollowingFriends.get(i).screenName)
			} else {
				println("Failure")
			}
		} 
	}
}