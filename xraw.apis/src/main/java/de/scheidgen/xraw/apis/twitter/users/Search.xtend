package de.scheidgen.xraw.apis.twitter.users

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Required
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterUser
import de.scheidgen.xraw.annotations.TestMockupRequest

/**
 * Provides a simple, relevance-based search interface to public user accounts on Twitter. Try querying by topical interest, full name, company name, location, or other criteria. Exact match searches are not supported.
 * <br/>
 * <br/>
 * Only the first 1,000 matching results are available.
 * <ul>
 * <li>Requires authentication? Yes (user context only)</li>
 * <li>Rate limited? Yes</li>
 * <li>Requests / 15-min window (user auth): 180</li> 
 * </ul>
 */
@TestMockupRequest
@Request(url="https://api.twitter.com/1.1/users/search.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterUser, isList=true))
class Search {
	/**
	 * The search query to run against people search.
	 */
	@Required String q

	/**
	 * Specifies the page of results to retrieve.
	 */
	int page

	/**
	 * The number of potential user results to retrieve per page. This value has a maximum of 20.
	 */
	int count

	/**
	 * The entities node will be disincluded from embedded tweet objects when set to false.
	 */
	boolean include_entities
}