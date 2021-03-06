package de.scheidgen.xraw.apis.twitter.followers

import de.scheidgen.xraw.annotations.OrConstraint
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterIdCursor
import de.scheidgen.xraw.annotations.TestMockupRequest

/**
 * Returns a cursored collection of user IDs for every user the specified user is following (otherwise known as their “friends”).
 * <br/><br/>At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 5,000 user IDs and multiple “pages” of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 * <br/><br/>This method is especially powerful when used in conjunction with GET users / lookup, a method that allows you to convert user IDs into full user objects in bulk.
 * <ul>
 * <li>Requires authentication? Yes</li>
 * <li>Rate limited? Yes</li>
 * <li>Requests / 15-min window (user auth): 15</li>
 * <li>Requests / 15-min window (app auth): 15</li>
 * </ul>
 * Either a screen_name or a user_id must be provided.
 */
 @Request(url="https://api.twitter.com/1.1/followers/ids.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterIdCursor))
 @OrConstraint("user_id", "screen_name")
 @TestMockupRequest
class Id {
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
	 * Many programming environments will not consume our Tweet ids due to their size. Provide this option to have ids returned as strings instead. More about Twitter IDs. 
	 */
	boolean stringify_ids

	/**
	 * Specifies the number of IDs attempt retrieval of, up to a maximum of 5,000 per distinct request. The value of count is best thought of as a limit to the number of results to return. When using the count parameter with this method, it is wise to use a consistent count value across all requests to the same user’s collection. Usage of this parameter is encouraged in environments where all 5,000 IDs constitutes too large of a response. 
	 */
	 int count
}