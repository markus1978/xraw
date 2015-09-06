package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.search.SearchResultType
import de.scheidgen.xraw.SocialScript

class TwitterExample {
	
	static def void main(String[] args) {		
		val twitter = SocialScript::createWithStore("data/store.xmi").serviceWithLogin(Twitter, "markus")
		
		val userTimeline = twitter.statuses.userTimeline.count(100).send
		val firstTweetId = userTimeline.get(0).id
		val firstTweet = twitter.statuses.show.id(firstTweetId).send
		
		println(firstTweet.user.location)
		
		for (status: twitter.search.tweets.q("Barack Obama").resultType(SearchResultType.popular).send.statuses) {
			println("# " + status.retweetCount + ":" + status.text)
		}
	}
}