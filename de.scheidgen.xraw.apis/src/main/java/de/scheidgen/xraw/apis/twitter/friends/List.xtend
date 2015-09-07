package de.scheidgen.xraw.apis.twitter.friends

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.apis.twitter.response.TwitterUserCursor
import org.scribe.model.Verb

/**
 * Returns a cursored collection of user objects for every user the specified user is following (otherwise known as their “friends”).
 * <br/><br/>
 * At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple “pages” of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 * <ul>
 * <li>Requires authentication? Yes</li>
 * <li>Rate limited? Yes</li>
 * <li>Requests / 15-min window (user auth): 15</li>
 * <li>Requests / 15-min window (app auth): 30</li>
 * </ul>
 * Either a screen_name or a user_id must be provided.
 */
 @Request(method=Verb.GET, url="https://api.twitter.com/1.1/friends/list.json", returnType=TwitterUserCursor)
class List {
	/**
	 * The ID of the user for whom to return results for.
	 */
	String user_id
	/**
	 * The screen name of the user for whom to return results for.
	 */
	String screen_name

	/**
	 * Causes the list of connections to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first “page.”
	 * <br/><br/>The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. See Using cursors to navigate collections for more information.
	 */
	String cursor

	/**
	 * Specifies the number of IDs attempt retrieval of, up to a maximum of 5,000 per distinct request. The value of count is best thought of as a limit to the number of results to return. When using the count parameter with this method, it is wise to use a consistent count value across all requests to the same user’s collection. Usage of this parameter is encouraged in environments where all 5,000 IDs constitutes too large of a response. 
	 */
	 int count
	 
	/**
	 * When set to either true, t or 1 statuses will not be included in the returned user objects. 
	 */
	boolean skip_status
	 
	/**
	 * The user object entities node will be disincluded when set to false.
	 */
	boolean include_user_entities

}