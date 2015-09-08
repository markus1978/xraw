package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.search.SearchResultType
import de.scheidgen.xraw.XRawScript

class TwitterExample {
	
	static def void main(String[] args) {		
		val twitter = XRawScript::createWithStore("data/store.xmi").serviceWithLogin(Twitter, "markus")
		
		val userTimeline = twitter.statuses.userTimeline.count(100).xResults
		val firstTweetId = userTimeline.get(0).id
		val firstTweet = twitter.statuses.show.id(firstTweetId).xResult
		
		println(firstTweet.user.location)
		
		val searchResults = twitter.search.tweets.q("Barack Obama").resultType(SearchResultType.popular).xResult
		for (status: searchResults.statuses) {
			println("# " + status.retweetCount + ":" + status.text)
		}
	}
}