package de.scheidgen.xraw.apis.twitter.followers

import de.scheidgen.xraw.annotations.OrConstraint
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterUserCursor

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
 @Request(url="https://api.twitter.com/1.1/followers/list.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterUserCursor))
 @OrConstraint("screen_name", "user_id")
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
	 * The number of users to return per page, up to a maximum of 200. Defaults to 20. 
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