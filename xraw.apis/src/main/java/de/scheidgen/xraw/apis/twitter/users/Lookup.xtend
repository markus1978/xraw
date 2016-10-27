package de.scheidgen.xraw.apis.twitter.users

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterUser
import java.util.List
import de.scheidgen.xraw.annotations.TestMockupRequest

/**
 * Returns fully-hydrated user objects for up to 100 users per request, as specified by comma-separated
 * values passed to the user_id and/or screen_name parameters. 
 * <br/>
 * This method is especially useful when used in conjunction with collections of user IDs returned from
 * GET friends / ids and GET followers / ids.
 * <br/>
 * GET users / show is used to retrieve a single user object.
 * <br/>
 * There are a few things to note when using this method.
 * <ul>
 * <li>You must be following a protected user to be able to see their most recent status update. If you don’t follow a protected user their status will be removed.</li>
 * <li>The order of user IDs or screen names may not match the order of users in the returned array.</li>
 * <li>If a requested user is unknown, suspended, or deleted, then that user will not be returned in the results list.</li>
 * <li>If none of your lookup criteria can be satisfied by returning a user object, a HTTP 404 will be thrown.</li>
 * <li>You are strongly encouraged to use a POST for larger requests.</li>
 * </ul>
 * 
 * <ul>
 * <li>Requires authentication? Yes</li>
 * <li>Rate limited? Yes</li>
 * <li>Requests / 15-min window (user auth): 180</li>
 * <li>Requests / 15-min window (app auth): 60</li>
 * </ul>		
 */
@Request(url="https://api.twitter.com/1.1/users/lookup.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterUser, isList=true))
@TestMockupRequest
class Lookup {
	/**
	 * A comma separated list of screen names, up to 100 are allowed in a single request. You are strongly encouraged to use a POST for larger (up to 100 screen names) requests.
	 */
	List<String> screen_name

	/**
	 * A comma separated list of user IDs, up to 100 are allowed in a single request. You are strongly encouraged to use a POST for larger requests.
	 */
	List<String> user_id
	
	/**
	 * The entities node that may appear within embedded statuses will be disincluded when set to false.
	 */
	boolean include_entities
}