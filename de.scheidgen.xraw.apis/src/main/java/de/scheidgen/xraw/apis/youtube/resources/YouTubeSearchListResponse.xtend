package de.scheidgen.xraw.apis.youtube.resources

import de.scheidgen.xraw.annotations.Resource
import java.util.List

@Resource
class YouTubeSearchListResponse {

    /**
     * The token that can be used as the value of the pageToken parameter to retrieve the next page in the result set.
     */
    String nextPageToken
    
    /**
     * The token that can be used as the value of the pageToken parameter to retrieve the previous page in the result set.
     */
  	String prevPageToken
  
  	YouTubeSearchListResponsePageInfo pageInfo
  	
  	/**
  	 * A list of results that match the search criteria.
  	 */
 	List<YouTubeSearchResult> items  
}

@Resource
class YouTubeSearchListResponsePageInfo {
	/**
	 * The total number of results in the result set.Please note that the value is an approximation and may not represent an exact value. In addition, the maximum value is 1,000,000.
	 * You should not use this value to create pagination links. Instead, use the nextPageToken and prevPageToken property values to determine whether to show pagination links.
	 */
	int totalResults
	
	/**
	 * The number of results included in the API response.
	 */
    int resultsPerPage
}