package de.scheidgen.social.twitter

import de.scheidgen.social.core.annotations.Request
import org.scribe.model.Verb
import de.scheidgen.social.core.annotations.Name
import de.scheidgen.social.core.annotations.Required

@Request(method=Verb.GET, url="https://api.twitter.com/1.1/statuses/show.json", returnType=String)
class TwitterStatusesShow {
	@Required String id;
	@Name("trim_user") boolean trimUser;
}