package de.scheidgen.xraw.apis.twitter.friendships

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterIdCursor
import de.scheidgen.xraw.annotations.TestMockupRequest

/** 
 * Returns a collection of numeric IDs for every user who has a pending request to 
 * follow the authenticating user.
 *
 * <ul>
 * <li>Response formats: JSON</li>
 * <li>Requires authentication? Yes (user context only)</li>
 * <li>Rate limited?: Yes</li>
 * <li>Requests / 15-min window (user auth): 15</li>
 * </ul>
 */

@Request(url="https://api.twitter.com/1.1/friendships/incoming.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterIdCursor))
@TestMockupRequest
class Incoming {
	/** 
	 * Causes the list of connections to be broken into pages of no more than 5000 IDs
	 * at a time. The number of IDs returned is not guaranteed to be 5000 as suspended 
	 * users are filtered out after connections are queried. If no cursor is provided, 
	 * a value of -1 will be assumed, which is the first “page.”
	 * 
	 * The response from the API will include a previous_cursor and next_cursor to allow 
	 * paging back and forth. See [node:10362, title=”Using cursors to navigate collections”] 
	 * for more information.
	 */	
	String cursor
	
	/** 
	 * Many programming environments will not consume our Tweet ids due to their size. Provide 
	 * this option to have ids returned as strings instead. More about [node:194].
	 */	
	boolean stringify_ids
}