package de.scheidgen.xraw.apis.twitter.statuses

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterStatus

@Request(url="https://api.twitter.com/1.1/statuses/show.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterStatus))
class Show {
	/**
	 * The numerical ID of the desired Tweet.
	 */
	String id

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