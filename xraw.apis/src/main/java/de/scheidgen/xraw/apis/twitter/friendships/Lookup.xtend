package de.scheidgen.xraw.apis.twitter.friendships

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.TestMockupRequest
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterFriendship
import java.util.List

/**
 * Returns the relationships of the authenticating user to the comma-separated list of up to 100 screen_names or user_ids provided. Values for connections can be: following, following_requested, followed_by, none, blocking, muting.
 * <ul>
 * <li>Requires authentication? Yes</li>
 * <li>Rate limited? Yes (user context only)</li>
 * <li>Requests / 15-min window (user auth): 15</li>
 * </ul>
 */
@Request(url="https://api.twitter.com/1.1/friendships/lookup.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterFriendship, isList=true))
@TestMockupRequest
class Lookup {
	/**
	 * A comma separated list of screen names, up to 100 are allowed in a single request.
	 */
	List<String> screen_name

	/**
	 * A comma separated list of user IDs, up to 100 are allowed in a single request.
	 */
	List<String> user_id
}