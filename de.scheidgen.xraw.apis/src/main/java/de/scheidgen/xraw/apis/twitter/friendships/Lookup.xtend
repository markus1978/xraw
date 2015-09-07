package de.scheidgen.xraw.apis.twitter.friendships

import org.scribe.model.Verb
import de.scheidgen.xraw.annotations.Request
import java.util.List
import de.scheidgen.xraw.apis.twitter.response.TwitterFriendship
import de.scheidgen.xraw.annotations.ReturnsList

/**
 * Returns the relationships of the authenticating user to the comma-separated list of up to 100 screen_names or user_ids provided. Values for connections can be: following, following_requested, followed_by, none, blocking, muting.
 * <ul>
 * <li>Requires authentication? Yes</li>
 * <li>Rate limited? Yes (user context only)</li>
 * <li>Requests / 15-min window (user auth): 15</li>
 * </ul>
 */
@Request(method=Verb.GET, url="https://api.twitter.com/1.1/friendships/lookup.json",returnType=TwitterFriendship)
@ReturnsList
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