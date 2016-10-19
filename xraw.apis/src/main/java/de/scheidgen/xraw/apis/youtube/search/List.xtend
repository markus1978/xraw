package de.scheidgen.xraw.apis.youtube.search

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Required
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.WithConverter
import de.scheidgen.xraw.annotations.XorOrNothingConstraint
import de.scheidgen.xraw.apis.youtube.YouTubeDateConverter
import de.scheidgen.xraw.apis.youtube.resources.YouTubeSearchListResponse
import java.util.Date

@Request(url="https://www.googleapis.com/youtube/v3/search", response=@Response(resourceType=YouTubeSearchListResponse))
@XorOrNothingConstraint("forContentOwner", "forDeveloper", "forMine", "relatedToVideoId")
class List {
	/**
	 * The <code><strong><span>part</span></strong></code> parameter specifies a comma-separated list of one or more <code><span>search</span></code> resource properties that the API response will include. Set the parameter value to <code><span>snippet</span></code>.
	 */
	@Required String part = "snippet"

	/**
	 * This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. <strong>Note:</strong> This parameter is intended exclusively for YouTube content partners.<br><br>The <code><strong><span>forContentOwner</span></strong></code> parameter restricts the search to only retrieve resources owned by the content owner specified by the <code><strong><span>onBehalfOfContentOwner</span></strong></code> parameter. The user must be authenticated using a CMS account linked to the specified content owner and <code><strong><span>onBehalfOfContentOwner</span></strong></code> must be provided.
	 */
	boolean forContentOwner

	/**
	 * This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. The <code><strong><span>forDeveloper</span></strong></code> parameter restricts the search to only retrieve videos uploaded via the developer's application or website. The API server uses the request's authorization credentials to identify the developer. The <code><span>forDeveloper</span></code> parameter can be used in conjunction with optional search parameters like the <code><span>q</span></code> parameter.<br><br>For this feature, each uploaded video is automatically tagged with the project number that is associated with the developer's application in the <a href="https://console.developers.google.com">Google Developers Console</a>.<br><br>When a search request subsequently sets the <code><span>forDeveloper</span></code> parameter to <code><span>true</span></code>, the API server uses the request's authorization credentials to identify the developer. Therefore, a developer can restrict results to videos uploaded through the developer's own app or website but not to videos uploaded through other apps or sites.
	 */
	boolean forDeveloper

	/**
	 * This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. The <code><strong><span>forMine</span></strong></code> parameter restricts the search to only retrieve videos owned by the authenticated user. If you set this parameter to <code><span>true</span></code>, then the <code><span>type</span></code> parameter's value must also be set to <code><span>video</span></code>.
	 */
	boolean forMine

	/**
	 * The <code><strong><span>relatedToVideoId</span></strong></code> parameter retrieves a list of videos that are related to the video that the parameter value identifies. The parameter value must be set to a YouTube video ID and, if you are using this parameter, the <code><span>type</span></code> parameter must be set to <code><span>video</span></code>.
	 */
	String relatedToVideoId

	/**
	 * The <code><strong><span>channelId</span></strong></code> parameter indicates that the API response should only contain resources created by the channel
	 */
	String channelId

	/**
	 * The <code><strong><span>channelType</span></strong></code> parameter lets you restrict a search to a particular type of channel.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>any</strong></code> – Return all channels.</li> 
	 *   <li><code><strong>show</strong></code> – Only retrieve shows.</li> 
	 *  </ul>
	 */
	String channelType

	/**
	 * The <code><strong><span>eventType</span></strong></code> parameter restricts a search to broadcast events. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>completed</strong></code> – Only include completed broadcasts.</li> 
	 *   <li><code><strong>live</strong></code> – Only include active broadcasts.</li> 
	 *   <li><code><strong>upcoming</strong></code> – Only include upcoming broadcasts.</li> 
	 *  </ul>
	 */
	String eventType

	/**
	 * The <code><strong><span>location</span></strong></code> parameter, in conjunction with the <code><span>locationRadius</span></code> parameter, defines a circular geographic area and also restricts a search to videos that specify, in their metadata, a geographic location that falls within that area. The parameter value is a string that specifies latitude/longitude coordinates e.g. (<code><span>37.<wbr>42307,<wbr>-122.<wbr>08427</span></code>).<br><br>
	 *  <ul>
	 *   <li>The <code>location</code> parameter value identifies the point at the center of the area.</li>
	 *   <li>The <code>locationRadius</code> parameter specifies the maximum distance that the location associated with a video can be from that point for the video to still be included in the search results.</li>
	 *  </ul>The API returns an error if your request specifies a value for the <code><span>location</span></code> parameter but does not also specify a value for the <code><span>locationRadius</span></code> parameter.
	 */
	String location

	/**
	 * The <code><strong><span>locationRadius</span></strong></code> parameter, in conjunction with the <code><span>location</span></code> parameter, defines a circular geographic area.<br><br>The parameter value must be a floating point number followed by a measurement unit. Valid measurement units are <code><span>m</span></code>, <code><span>km</span></code>, <code><span>ft</span></code>, and <code><span>mi</span></code>. For example, valid parameter values include <code><span>1500m</span></code>, <code><span>5km</span></code>, <code><span>10000ft</span></code>, and <code><span>0.<wbr>75mi</span></code>. The API does not support <code><span>locationRadius</span></code> parameter values larger than 1000 kilometers.<br><br><strong>Note:</strong> See the definition of the <code><a href="#location"><span>location</span></a></code> parameter for more information.
	 */
	String locationRadius

	/**
	 * The <code><strong><span>maxResults</span></strong></code> parameter specifies the maximum number of items that should be returned in the result set. Acceptable values are <code><span>0</span></code> to <code><span>50</span></code>, inclusive. The default value is <code><span>5</span></code>.
	 */
	int maxResults

	/**
	 * This parameter can only be used in a properly <a href="/youtube/v3/guides/authentication">authorized request</a>. <strong>Note:</strong> This parameter is intended exclusively for YouTube content partners.<br><br>The <code><strong><span>onBehalfOfContentOwner</span></strong></code> parameter indicates that the request's authorization credentials identify a YouTube CMS user who is acting on behalf of the content owner specified in the parameter value. This parameter is intended for YouTube content partners that own and manage many different YouTube channels. It allows content owners to authenticate once and get access to all their video and channel data, without having to provide authentication credentials for each individual channel. The CMS account that the user authenticates with must be linked to the specified YouTube content owner.
	 */
	String onBehalfOfContentOwner

	/**
	 * The <code><strong><span>order</span></strong></code> parameter specifies the method that will be used to order resources in the API response. The default value is <code><span>relevance</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>date</strong></code> – Resources are sorted in reverse chronological order based on the date they were created.</li> 
	 *   <li><code><strong>rating</strong></code> – Resources are sorted from highest to lowest rating.</li> 
	 *   <li><code><strong>relevance</strong></code> – Resources are sorted based on their relevance to the search query. This is the default value for this parameter.</li> 
	 *   <li><code><strong>title</strong></code> – Resources are sorted alphabetically by title.</li> 
	 *   <li><code><strong>videoCount</strong></code> – Channels are sorted in descending order of their number of uploaded videos.</li> 
	 *   <li><code><strong>viewCount</strong></code> – Resources are sorted from highest to lowest number of views.</li> 
	 *  </ul>
	 */
	String order

	/**
	 * The <code><strong><span>pageToken</span></strong></code> parameter identifies a specific page in the result set that should be returned. In an API response, the <code><span>nextPageToken</span></code> and <code><span>prevPageToken</span></code> properties identify other pages that could be retrieved.
	 */
	String pageToken

	/**
	 * The <code><strong><span>publishedAfter</span></strong></code> parameter indicates that the API response should only contain resources created after the specified time. The value is an RFC 3339 formatted date-time value (1970-01-01T00:00:00Z).
	 */
	@WithConverter(YouTubeDateConverter) Date publishedAfter

	/**
	 * The <code><strong><span>publishedBefore</span></strong></code> parameter indicates that the API response should only contain resources created before the specified time. The value is an RFC 3339 formatted date-time value (1970-01-01T00:00:00Z).
	 */
	@WithConverter(YouTubeDateConverter) Date publishedBefore

	/**
	 * The <code><strong><span>q</span></strong></code> parameter specifies the query term to search for.<br><br>Your request can also use the Boolean NOT (<code><span>-</span></code>) and OR (<code><span>|<wbr></span></code>) operators to exclude videos or to find videos that are associated with one of several search terms. For example, to search for videos matching either "boating" or "sailing", set the <code><span>q</span></code> parameter value to <code><span>boating|<wbr>sailing</span></code>. Similarly, to search for videos matching either "boating" or "sailing" but not "fishing", set the <code><span>q</span></code> parameter value to <code><span>boating|<wbr>sailing -fishing</span></code>. Note that the pipe character must be URL-escaped when it is sent in your API request. The URL-escaped value for the pipe character is <code><span>%7C</span></code>.
	 */
	String q

	/**
	 * The <code><strong><span>regionCode</span></strong></code> parameter instructs the API to return search results for the specified country. The parameter value is an <a href="http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm">ISO 3166-1 alpha-2</a> country code.
	 */
	String regionCode

	/**
	 * The <code><strong><span>relevanceLanguage</span></strong></code> parameter instructs the API to return search results that are most relevant to the specified language. The parameter value is typically an <a href="http://www.loc.gov/standards/iso639-2/php/code_list.php">ISO 639-1 two-letter language code</a>. However, you should use the values <code><span>zh-Hans</span></code> for simplified Chinese and <code><span>zh-Hant</span></code> for traditional Chinese. Please note that results in other languages will still be returned if they are highly relevant to the search query term.
	 */
	String relevanceLanguage

	/**
	 * The <code><strong><span>safeSearch</span></strong></code> parameter indicates whether the search results should include restricted content as well as standard content.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>moderate</strong></code> – YouTube will filter some content from search results and, at the least, will filter content that is restricted in your locale. Based on their content, search results could be removed from search results or demoted in search results. This is the default parameter value.</li> 
	 *   <li><code><strong>none</strong></code> – YouTube will not filter the search result set.</li> 
	 *   <li><code><strong>strict</strong></code> – YouTube will try to exclude all restricted content from the search result set. Based on their content, search results could be removed from search results or demoted in search results.</li> 
	 *  </ul>
	 */
	String safeSearch

	/**
	 * The <code><strong><span>topicId</span></strong></code> parameter indicates that the API response should only contain resources associated with the specified topic. The value identifies a <a href="//wiki.freebase.com/wiki/Freebase_API">Freebase topic ID</a>.
	 */
	String topicId

	/**
	 * The <code><strong><span>type</span></strong></code> parameter restricts a search query to only retrieve a particular type of resource. The value is a comma-separated list of resource types. The default value is <code><span>video,<wbr>channel,<wbr>playlist</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>channel</strong></code></li>
	 *   <li><code><strong>playlist</strong></code></li>
	 *   <li><code><strong>video</strong></code></li>
	 *  </ul>
	 */
	String type

	/**
	 * The <code><strong><span>videoCaption</span></strong></code> parameter indicates whether the API should filter video search results based on whether they have captions. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>any</strong></code> – Do not filter results based on caption availability.</li> 
	 *   <li><code><strong>closedCaption</strong></code> – Only include videos that have captions.</li> 
	 *   <li><code><strong>none</strong></code> – Only include videos that do not have captions.</li> 
	 *  </ul>
	 */
	String videoCaption

	/**
	 * The <code><strong><span>videoCategoryId</span></strong></code> parameter filters video search results based on their <a href="/youtube/v3/docs/videoCategories">category</a>. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.
	 */
	String videoCategoryId

	/**
	 * The <code><strong><span>videoDefinition</span></strong></code> parameter lets you restrict a search to only include either high definition (HD) or standard definition (SD) videos. HD videos are available for playback in at least 720p, though higher resolutions, like 1080p, might also be available. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>any</strong></code> – Return all videos, regardless of their resolution.</li> 
	 *   <li><code><strong>high</strong></code> – Only retrieve HD videos.</li> 
	 *   <li><code><strong>standard</strong></code> – Only retrieve videos in standard definition.</li> 
	 *  </ul>
	 */
	String videoDefinition

	/**
	 * The <code><strong><span>videoDimension</span></strong></code> parameter lets you restrict a search to only retrieve 2D or 3D videos. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>2d</strong></code> – Restrict search results to exclude 3D videos.</li> 
	 *   <li><code><strong>3d</strong></code> – Restrict search results to only include 3D videos.</li> 
	 *   <li><code><strong>any</strong></code> – Include both 3D and non-3D videos in returned results. This is the default value.</li> 
	 *  </ul>
	 */
	String videoDimension

	/**
	 * The <code><strong><span>videoDuration</span></strong></code> parameter filters video search results based on their duration. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>any</strong></code> – Do not filter video search results based on their duration. This is the default value.</li> 
	 *   <li><code><strong>long</strong></code> – Only include videos longer than 20 minutes.</li> 
	 *   <li><code><strong>medium</strong></code> – Only include videos that are between four and 20 minutes long (inclusive).</li> 
	 *   <li><code><strong>short</strong></code> – Only include videos that are less than four minutes long.</li> 
	 *  </ul>
	 */
	String videoDuration

	/**
	 * The <code><strong><span>videoEmbeddable</span></strong></code> parameter lets you to restrict a search to only videos that can be embedded into a webpage. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>any</strong></code> – Return all videos, embeddable or not.</li> 
	 *   <li><code><strong>true</strong></code> – Only retrieve embeddable videos.</li> 
	 *  </ul>
	 */
	String videoEmbeddable

	/**
	 * The <code><strong><span>videoLicense</span></strong></code> parameter filters search results to only include videos with a particular license. YouTube lets video uploaders choose to attach either the Creative Commons license or the standard YouTube license to each of their videos. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>any</strong></code> – Return all videos, regardless of which license they have, that match the query parameters.</li> 
	 *   <li><code><strong>creativeCommon</strong></code> – Only return videos that have a Creative Commons license. Users can reuse videos with this license in other videos that they create. <a href="http://www.google.com/support/youtube/bin/answer.py?answer=1284989">Learn more</a>.</li> 
	 *   <li><code><strong>youtube</strong></code> – Only return videos that have the standard YouTube license.</li> 
	 *  </ul>
	 */
	String videoLicense

	/**
	 * The <code><strong><span>videoSyndicated</span></strong></code> parameter lets you to restrict a search to only videos that can be played outside youtube.com. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>any</strong></code> – Return all videos, syndicated or not.</li> 
	 *   <li><code><strong>true</strong></code> – Only retrieve syndicated videos.</li> 
	 *  </ul>
	 */
	String videoSyndicated

	/**
	 * The <code><strong><span>videoType</span></strong></code> parameter lets you restrict a search to a particular type of videos. If you specify a value for this parameter, you must also set the <code><a href="#type"><span>type</span></a></code> parameter's value to <code><span>video</span></code>.<br><br>Acceptable values are: 
	 *  <ul> 
	 *   <li><code><strong>any</strong></code> – Return all videos.</li> 
	 *   <li><code><strong>episode</strong></code> – Only retrieve episodes of shows.</li> 
	 *   <li><code><strong>movie</strong></code> – Only retrieve movies.</li> 
	 *  </ul>
	 */
	String videoType

}