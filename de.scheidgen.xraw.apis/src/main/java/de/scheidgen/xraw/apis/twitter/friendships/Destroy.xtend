package de.scheidgen.xraw.apis.twitter.friendships

import de.scheidgen.xraw.annotations.Request
import org.scribe.model.Verb
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.response.TwitterUser
import de.scheidgen.xraw.apis.twitter.TwitterResponse

/**
 * Allows the authenticating user to unfollow the user specified in the ID parameter.
 * <br/><br/
 * Returns the unfollowed user in the requested format when successful. Returns a string describing the failure condition when unsuccessful.
 * <br/><br/
 * Actions taken in this method are asynchronous and changes will be eventually consistent.
 * <ul>
 * <li>Requires authentication? (user context only)</li>
 * <li>Rate limited? Yes</li>
 * </ul>
 */
@Request(url="https://api.twitter.com/1.1/friendships/destroy.json", method=Verb.POST, response=@Response(resourceType=TwitterUser, responseType=TwitterResponse))
class Destroy {
	/**
	 * The screen name of the user for whom to unfollow.
	 */
	String screen_name
	
	/**
	 * The ID of the user for whom to unfollow.
	 */	
	String user_id
}