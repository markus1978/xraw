package de.scheidgen.xraw.examples

import com.github.scribejava.apis.TwitterApi
import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.search.SearchResultType
import de.scheidgen.xraw.http.ScribeOAuth1Service
import de.scheidgen.xraw.script.XRawScript

class TwitterExample {
	
	static def void main(String[] args) {		
		val twitter = XRawScript::get("data/store.json", "markus", Twitter) [new ScribeOAuth1Service(TwitterApi.instance, it)]
		
		val userTimeline = twitter.statuses.userTimeline.count(100).xResult
		val firstTweetId = userTimeline.get(0).id
		val firstTweet = twitter.statuses.show.id(firstTweetId).xResult
		
		println(firstTweet.user.location)
		
		val searchResults = twitter.search.tweets.q("Obama").resultType(SearchResultType.popular)
		for (status: searchResults.xResult.statuses) {
			println("# " + status.retweetCount + ":" + status.text + " at " + status.createdAt)
		}

		println(searchResults.xResponse.rateLimitRemaining)
	}
}