package de.scheidgen.xraw.apis.youtube.channels

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.youtube.resources.YouTubeChannelsListResponse

@Request(url="https://www.googleapis.com/youtube/v3/channels", response=@Response(resourceType=YouTubeChannelsListResponse))
class List {
	/**
	 * The <code><strong>part</strong></code> parameter specifies a comma-separated list of one or more <code>channel</code> resource properties that the API response will include.<br><br>If the parameter identifies a property that contains child properties, the child properties will be included in the response. For example, in a <code>channel</code> resource, the <code>contentDetails</code> property contains other properties, such as the <code>uploads</code> properties. As such, if you set <code><strong>part=contentDetails</strong></code>, the API response will also contain all of those nested properties.<br><br>The list below contains the <code>part</code> names that you can include in the parameter value and the <a href="/youtube/v3/getting-started#quota">quota cost</a> for each part:<br>
	 <ul> 
	  <li><code>auditDetails</code>: 4</li> 
	  <li><code>brandingSettings</code>: 2</li> 
	  <li><code>contentDetails</code>: 2</li> 
	  <li><code>contentOwnerDetails</code>: 2</li> 
	  <li><code>id</code>: 0</li> 
	  <li><code>invideoPromotion</code>: 2</li> 
	  <li><code>snippet</code>: 2</li> 
	  <li><code>statistics</code>: 2</li> 
	  <li><code>status</code>: 2</li> 
	  <li><code>topicDetails</code>: 2</li> 
	 </ul>
	 */
	String part
	
	/**
	 * The <code><strong>categoryId</strong></code> parameter specifies a <a href="/youtube/v3/docs/guideCategories">YouTube guide category</a>, thereby requesting YouTube channels associated with that category.
	 */
	String categoryId
	
	/**
	 * The <code><strong>forUsername</strong></code> parameter specifies a YouTube username, thereby requesting the channel associated with that username.
	 */
	String forUsername
	
	/**
	 * The <code><strong>id</strong></code> parameter specifies a comma-separated list of the YouTube channel ID(s) for the resource(s) that are being retrieved. In a <code>channel</code> resource, the <code>id</code> property specifies the channel's YouTube channel ID.
	 */
	String id
	
	/**
	 * This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. <strong>Note:</strong> This parameter is intended exclusively for YouTube content partners.<br><br>Set this parameter's value to <code>true</code> to instruct the API to only return channels managed by the content owner that the <code><strong>onBehalfOfContentOwner</strong></code> parameter specifies. The user must be authenticated as a CMS account linked to the specified content owner and <code><strong>onBehalfOfContentOwner</strong></code> must be provided.
	 */
	boolean managedByMe
	
	/**
	 * This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. Set this parameter's value to <code>true</code> to instruct the API to only return channels owned by the authenticated user.
	 */
	boolean mine
	
	/**
	 * <span style="color:red">This parameter has been deprecated. </span>This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. Use the <code><a href="/youtube/v3/docs/subscriptions/list">subscriptions.list</a></code> method and its <code>mySubscribers</code> parameter to retrieve a list of subscribers to the authenticated user's channel.
	 */
	boolean mySubscribers
	
	/**
	 * The <code><strong>maxResults</strong></code> parameter specifies the maximum number of items that should be returned in the result set. Acceptable values are <code>0</code> to <code>50</code>, inclusive. The default value is <code>5</code>.
	 */
	int maxResults
	
	/**
	 * This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. <strong>Note:</strong> This parameter is intended exclusively for YouTube content partners.<br><br>The <code><strong>onBehalfOfContentOwner</strong></code> parameter indicates that the request's authorization credentials identify a YouTube CMS user who is acting on behalf of the content owner specified in the parameter value. This parameter is intended for YouTube content partners that own and manage many different YouTube channels. It allows content owners to authenticate once and get access to all their video and channel data, without having to provide authentication credentials for each individual channel. The CMS account that the user authenticates with must be linked to the specified YouTube content owner.
	 */
	String onBehalfOfContentOwner
	
	/**
	 * The <code><strong>pageToken</strong></code> parameter identifies a specific page in the result set that should be returned. In an API response, the <code>nextPageToken</code> and <code>prevPageToken</code> properties identify other pages that could be retrieved.
	 */
	String pageToken
	
}

