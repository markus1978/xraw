package de.scheidgen.xraw.apis.youtube.videos

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.youtube.resources.YouTubeVideosListResponse

@Request(url="https://www.googleapis.com/youtube/v3/videos", response=@Response(resourceType=YouTubeVideosListResponse))
class List {
	/**
	 * The <code><strong>part</strong></code> parameter specifies a comma-separated list of one or more <code>video</code> resource properties that the API response will include.<br><br>If the parameter identifies a property that contains child properties, the child properties will be included in the response. For example, in a <code>video</code> resource, the <code>snippet</code> property contains the <code>channelId</code>, <code>title</code>, <code>description</code>, <code>tags</code>, and <code>categoryId</code> properties. As such, if you set <code><strong>part=snippet</strong></code>, the API response will contain all of those properties.<br><br>The list below contains the <code>part</code> names that you can include in the parameter value and the <a href="/youtube/v3/getting-started#quota">quota cost</a> for each part:<br>
	 <ul> 
	  <li><code>contentDetails</code>: 2</li> 
	  <li><code>fileDetails</code>: 1</li> 
	  <li><code>id</code>: 0</li> 
	  <li><code>liveStreamingDetails</code>: 2</li> 
	  <li><code>player</code>: 0</li> 
	  <li><code>processingDetails</code>: 1</li> 
	  <li><code>recordingDetails</code>: 2</li> 
	  <li><code>snippet</code>: 2</li> 
	  <li><code>statistics</code>: 2</li> 
	  <li><code>status</code>: 2</li> 
	  <li><code>suggestions</code>: 1</li> 
	  <li><code>topicDetails</code>: 2</li> 
	 </ul>
	 */
	String part
	
	/**
	 * The <code><strong>chart</strong></code> parameter identifies the chart that you want to retrieve.<br><br>Acceptable values are: 
	 <ul> 
	  <li><code><strong>mostPopular</strong></code> – Return the most popular videos for the specified <a href="#regionCode">content region</a> and <a href="#videoCategoryId">video category</a>.</li> 
	 </ul>
	 */
	String chart
	
	/**
	 * The <code><strong>id</strong></code> parameter specifies a comma-separated list of the YouTube video ID(s) for the resource(s) that are being retrieved. In a <code>video</code> resource, the <code>id</code> property specifies the video's ID.
	 */
	String id
	
	/**
	 * This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. Set this parameter's value to <code>like</code> or <code>dislike</code> to instruct the API to only return videos liked or disliked by the authenticated user.<br><br>Acceptable values are: 
	 <ul> 
	  <li><code><strong>dislike</strong></code> – Returns only videos disliked by the authenticated user.</li> 
	  <li><code><strong>like</strong></code> – Returns only video liked by the authenticated user.</li> 
	 </ul>
	 */
	String myRating
	
	/**
	 * The <code><strong>maxResults</strong></code> parameter specifies the maximum number of items that should be returned in the result set.<br><br><strong>Note:</strong> This parameter is supported for use in conjunction with the <code><a href="#myRating">myRating</a></code> parameter, but it is not supported for use in conjunction with the <code><a href="#id">id</a></code> parameter. Acceptable values are <code>1</code> to <code>50</code>, inclusive. The default value is <code>5</code>.
	 */
	int maxResults
	
	/**
	 * This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. <strong>Note:</strong> This parameter is intended exclusively for YouTube content partners.<br><br>The <code><strong>onBehalfOfContentOwner</strong></code> parameter indicates that the request's authorization credentials identify a YouTube CMS user who is acting on behalf of the content owner specified in the parameter value. This parameter is intended for YouTube content partners that own and manage many different YouTube channels. It allows content owners to authenticate once and get access to all their video and channel data, without having to provide authentication credentials for each individual channel. The CMS account that the user authenticates with must be linked to the specified YouTube content owner.
	 */
	String onBehalfOfContentOwner
	
	/**
	 * The <code><strong>pageToken</strong></code> parameter identifies a specific page in the result set that should be returned. In an API response, the <code>nextPageToken</code> and <code>prevPageToken</code> properties identify other pages that could be retrieved.<br><br><strong>Note:</strong> This parameter is supported for use in conjunction with the <code><a href="#myRating">myRating</a></code> parameter, but it is not supported for use in conjunction with the <code><a href="#id">id</a></code> parameter.
	 */
	String pageToken
	
	/**
	 * The <code><strong>regionCode</strong></code> parameter instructs the API to select a video chart available in the specified region. This parameter can only be used in conjunction with the <code><a href="#chart">chart</a></code> parameter. The parameter value is an ISO 3166-1 alpha-2 country code.
	 */
	String regionCode
	
	/**
	 * The <code><strong>videoCategoryId</strong></code> parameter identifies the <a href="/youtube/v3/docs/videoCategories">video category</a> for which the chart should be retrieved. This parameter can only be used in conjunction with the <code><a href="#chart">chart</a></code> parameter. By default, charts are not restricted to a particular category. The default value is <code>0</code>.
	 */
	String videoCategoryId
	
}

