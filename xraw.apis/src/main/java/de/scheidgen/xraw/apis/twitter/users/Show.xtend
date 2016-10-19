package de.scheidgen.xraw.apis.twitter.users

import de.scheidgen.xraw.annotations.OrConstraint
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterUser
import de.scheidgen.xraw.annotations.TestMockupRequest

/**
 * Returns a variety of information about the user specified by the required user_id or screen_name parameter. The author’s most recent Tweet will be returned inline when possible.
 * <br/>
 * GET users / lookup is used to retrieve a bulk collection of user objects.
 * <br/>
 * You must be following a protected user to be able to see their most recent Tweet. If you don’t follow a protected user, the users Tweet will be removed. A Tweet will not always be returned in the current_status field.
 * 
 * <ul>
 * <li>Requires authentication? Yes</li>
 * <li>Rate limited? Yes</li>
 * <li>Requests / 15-min window (user auth): 180</li>
 * <li>Requests / 15-min window (app auth): 180</li>
 * </ul>	
 */
@Request(url="https://api.twitter.com/1.1/users/show.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterUser))
@OrConstraint("screen_name", "user_id")
@TestMockupRequest
class Show {
	/**
	 * The ID of the user for whom to return results for. Either an id or screen_name is required for this method.
	 */
	String user_id
	
	/**
	 * The screen name of the user for whom to return results for. Either a id or screen_name is required for this method.
	 */
	String screen_name

	/**
	 * The entities node will be disincluded when set to false. 
	 */
	 boolean include_entities
}