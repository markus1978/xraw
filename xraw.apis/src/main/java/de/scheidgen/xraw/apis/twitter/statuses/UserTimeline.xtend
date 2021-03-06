package de.scheidgen.xraw.apis.twitter.statuses

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterStatus

@Request(url="https://api.twitter.com/1.1/statuses/user_timeline.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterStatus, isList=true))
class UserTimeline {
	/**
	 * The ID of the user for whom to return results for.
	 */
	String user_id

	/**
	 * Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available.
	 */
	String since_id
	
	/**
	 * Specifies the number of tweets to try and retrieve, up to a maximum of 200 per distinct request. The value of count is best thought of as a limit to the number of tweets to return because suspended or deleted content is removed after the count has been applied. We include retweets in the count, even if include_rts is not supplied. It is recommended you always send include_rts=1 when using this API method.
	 */
	int count

	/**
	 * Returns results with an ID less than (that is, older than) or equal to the specified ID.
	 */	
	String max_id

	/**
	 * When set to either true, t or 1, each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object.
	 */
	boolean trim_user

	/**
	 * This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets — this is because the count parameter retrieves that many tweets before filtering out retweets and replies. This parameter is only supported for JSON and XML responses.
	 */
	boolean exclude_replies

	/**
	 * This parameter enhances the contributors element of the status response to include the screen_name of the contributor. By default only the user_id of the contributor is included.
	 */
	boolean contributor_details

	/**
	 * When set to false, the timeline will strip any native retweets (though they will still count toward both the maximal length of the timeline and the slice selected by the count parameter). Note: If you’re using the trim_user parameter in conjunction with include_rts, the retweets will still contain a full user object.
	 */
	boolean include_rts

}