package de.scheidgen.social.test

import de.scheidgen.social.twitter.Twitter

class Main {
	
	static def void main(String[] args) {
		val profile = SocialUtil::openProfile
		val twitter = Twitter.get(SocialUtil::getTwitterService(profile))
		
		val userTimeline = twitter.statuses.userTimeline.count(100).send
		val firstTweetId = userTimeline.get(0).id
		val firstTweet = twitter.statuses.show.id(firstTweetId).send
		
		println(firstTweet.text)
	}
}