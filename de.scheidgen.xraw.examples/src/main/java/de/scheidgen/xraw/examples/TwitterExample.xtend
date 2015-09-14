package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.search.SearchResultType
import de.scheidgen.xraw.script.XRawScript

class TwitterExample {
	
	static def void main(String[] args) {		
		val twitter = XRawScript::get("data/store.xmi", "markus", Twitter)
		
		val userTimeline = twitter.statuses.userTimeline.count(100).xResult
		val firstTweetId = userTimeline.get(0).id
		val firstTweet = twitter.statuses.show.id(firstTweetId).xResult
		
		println(firstTweet.user.location)
		
		val searchResults = twitter.search.tweets.q("Barack Obama").resultType(SearchResultType.popular)
		for (status: searchResults.xResult.statuses) {
			println("# " + status.retweetCount + ":" + status.text)
		}

		println(searchResults.xResponse.rateLimitRemaining)
	}
}