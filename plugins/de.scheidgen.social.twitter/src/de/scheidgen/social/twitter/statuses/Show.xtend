package de.scheidgen.social.twitter.statuses

import de.scheidgen.social.core.annotations.Name
import de.scheidgen.social.core.annotations.Request
import de.scheidgen.social.core.annotations.Required
import de.scheidgen.social.twitter.resources.TwitterTweet
import org.scribe.model.Verb

import static extension org.scribe.model.Verb.*

@Request(method=Verb.GET, url="https://api.twitter.com/1.1/statuses/show.json", returnType=TwitterTweet)
class Show {
	/**
	 * The numerical ID of the desired Tweet.
	 */
	@Required String id

	/**
	 * When set to either true, t or 1, each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object.
	 */
	@Name("trim_user") boolean trimUser

	/**
	 * When set to either true, t or 1, any Tweets returned that have been retweeted by the authenticating user will include an additional current_user_retweet node, containing the ID of the source status for the retweet.
	 */
	@Name("include_my_retweet") boolean includeMyRetweet

	/** 
	 * The entities node will be disincluded when set to false.
	 */
	@Name("include_entities") boolean includeEntities

}