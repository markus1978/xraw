package de.scheidgen.xraw.apis.youtube.resources

import de.scheidgen.xraw.annotations.Resource
import java.util.List

@Resource
class YouTubeChannelsListResponse extends AbstractYouTubeResource {
	/**
	 * The token that can be used as the value of the <code>pageToken</code> parameter to retrieve the next page in the result set.
	 */
	String nextPageToken
	
	/**
	 * The token that can be used as the value of the <code>pageToken</code> parameter to retrieve the previous page in the result set.
	 */
	String prevPageToken
	
	/**
	 * The <code>pageInfo</code> object encapsulates paging information for the result set.
	 */
	YouTubeChannelsListResponsePageInfo pageInfo
	
	/**
	 * A list of channels that match the request criteria.
	 */
	List<YouTubeChannels> items
	
}

@Resource
class YouTubeChannelsListResponsePageInfo {
	/**
	 * The total number of results in the result set.
	 */
	int totalResults
	
	/**
	 * The number of results included in the API response.
	 */
	int resultsPerPage
	
}


