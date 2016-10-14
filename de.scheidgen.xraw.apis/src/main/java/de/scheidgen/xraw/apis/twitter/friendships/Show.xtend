package de.scheidgen.xraw.apis.twitter.friendships

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterShowFriendship

/**
 * Returns detailed information about the relationship between two arbitrary users.
 * 
 * authentication only, ratelimit: 180/15
 */
@Request(url="https://api.twitter.com/1.1/friendships/show.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterShowFriendship))
class Show {
	/**
	 * The user_id of the subject user.
	 */
	String source_id
	
	/**
	 * The screen_name of the subject user.
	 */
	String source_screen_name

	/**
	 * The user_id of the target user.
	 */
	String target_id

	/**
	 * The screen_name of the target user.
	 */
	String target_screen_name
}