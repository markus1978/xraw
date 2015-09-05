package de.scheidgen.social.twitter.statuses

import de.scheidgen.social.core.annotations.Request
import de.scheidgen.social.core.annotations.ReturnsList
import de.scheidgen.social.twitter.resources.TwitterTweet
import org.scribe.model.Verb

import static extension org.scribe.model.Verb.*

@Request(method=Verb.GET, url="https://api.twitter.com/1.1/statuses/user_timeline.json", returnType=TwitterTweet)
@ReturnsList
class UserTimeline {
	
}