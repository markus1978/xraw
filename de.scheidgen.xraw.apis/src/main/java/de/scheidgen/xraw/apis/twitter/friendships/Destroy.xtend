package de.scheidgen.xraw.apis.twitter.friendships

import com.mashape.unirest.http.HttpMethod
import de.scheidgen.xraw.annotations.OrConstraint
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterUser

import static extension com.mashape.unirest.http.HttpMethod.*
import de.scheidgen.xraw.annotations.TestMockupRequest

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
@Request(url="https://api.twitter.com/1.1/friendships/destroy.json", method=HttpMethod.POST, response=@Response(resourceType=TwitterUser, responseType=TwitterResponse))
@OrConstraint("screen_name", "user_id")
@TestMockupRequest
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