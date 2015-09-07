package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.search.SearchResultType
import de.scheidgen.xraw.XRawScript

class TwitterExample {
	
	static def void main(String[] args) {		
		val twitter = XRawScript::createWithStore("data/store.xmi").serviceWithLogin(Twitter, "markus")
		
		val userTimeline = twitter.statuses.userTimeline.count(100).send
		val firstTweetId = userTimeline.get(0).id
		val firstTweet = twitter.statuses.show.id(firstTweetId).send
		
		println(firstTweet.user.location)
		
		val searchResults = twitter.search.tweets.q("Barack Obama").resultType(SearchResultType.popular).send
		for (status: searchResults.statuses) {
			println("# " + status.retweetCount + ":" + status.text)
		}
	}
}