package de.scheidgen.social.twitter.statuses

import de.scheidgen.social.annotations.Request
import de.scheidgen.social.annotations.Required
import de.scheidgen.social.twitter.response.TwitterStatus
import org.scribe.model.Verb

@Request(method=Verb.GET, url="https://api.twitter.com/1.1/statuses/show.json", returnType=TwitterStatus)
class Show {
	/**
	 * The numerical ID of the desired Tweet.
	 */
	@Required String id

	/**
	 * When set to either true, t or 1, each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object.
	 */
	boolean trim_user

	/**
	 * When set to either true, t or 1, any Tweets returned that have been retweeted by the authenticating user will include an additional current_user_retweet node, containing the ID of the source status for the retweet.
	 */
	boolean include_my_retweet

	/** 
	 * The entities node will be disincluded when set to false.
	 */
	boolean include_entities

}