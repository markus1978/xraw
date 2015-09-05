package de.scheidgen.social.test

import de.scheidgen.social.twitter.Twitter
import de.scheidgen.social.twitter.search.SearchResultType

class TwitterTest {
	
	static def void main(String[] args) {
		val profile = SocialUtil::openProfile
		val twitter = Twitter.get(SocialUtil::getTwitterService(profile))
		
		val userTimeline = twitter.statuses.userTimeline.count(100).send
		val firstTweetId = userTimeline.get(0).id
		val firstTweet = twitter.statuses.show.id(firstTweetId).send
		
		println(firstTweet.user.location)
		
		for (status: twitter.search.tweets.q("Barack Obama").resultType(SearchResultType.popular).send.statuses) {
			println("# " + status.retweetCount + ":" + status.text)
		}
	}
}