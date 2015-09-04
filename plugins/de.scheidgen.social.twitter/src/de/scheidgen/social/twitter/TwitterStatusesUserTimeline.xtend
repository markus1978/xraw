package de.scheidgen.social.twitter

import de.scheidgen.social.core.annotations.Request
import org.scribe.model.Verb
import de.scheidgen.social.core.annotations.ReturnsList

@Request(method=Verb.GET, url="https://api.twitter.com/1.1/statuses/user_timeline.json", returnType=TwitterTweet)
@ReturnsList
class TwitterStatusesUserTimeline {
	
}