package de.scheidgen.social.twitter.statuses

import de.scheidgen.social.core.annotations.Name
import de.scheidgen.social.core.annotations.Request
import de.scheidgen.social.core.annotations.Required
import de.scheidgen.social.twitter.resources.TwitterTweet
import org.scribe.model.Verb

import static extension org.scribe.model.Verb.*

@Request(method=Verb.GET, url="https://api.twitter.com/1.1/statuses/show.json", returnType=TwitterTweet)
class Show {
	@Required String id;
	@Name("trim_user") boolean trimUser;
}