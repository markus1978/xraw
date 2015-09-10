package de.scheidgen.xraw.apis.youtube.resources

import de.scheidgen.xraw.annotations.Resource
import de.scheidgen.xraw.annotations.WithConverter
import de.scheidgen.xraw.apis.youtube.YouTubeDateConverter
import java.util.Date
import java.util.List
import java.util.Map

@Resource
class YouTubeChannels extends AbstractYouTubeResource {
	/**
	 * The ID that YouTube uses to uniquely identify the channel.
	 */
	String id
	
	/**
	 * The <code>snippet</code> object contains basic details about the channel, such as its title, description, and thumbnail images.
	 */
	YouTubeChannelsSnippet snippet
	
	/**
	 * The <code>contentDetails</code> object encapsulates information about the channel's content.
	 */
	YouTubeChannelsContentDetails contentDetails
	
	/**
	 * The <code>statistics</code> object encapsulates statistics for the channel.
	 */
	YouTubeChannelsStatistics statistics
	
	/**
	 * The <code>topicDetails</code> object encapsulates information about <a href="http://www.freebase.com">Freebase</a> topics associated with the channel.
	 */
	YouTubeChannelsTopicDetails topicDetails
	
	/**
	 * The <code>status</code> object encapsulates information about the privacy status of the channel.
	 */
	YouTubeChannelsStatus status
	
	/**
	 * The <code>brandingSettings</code> object encapsulates information about the branding of the channel.
	 */
	YouTubeChannelsBrandingSettings brandingSettings
	
	/**
	 * The <code>invideoPromotion</code> object encapsulates information about a promotional campaign associated with the channel. A channel can use an in-video promotional campaign to display the thumbnail image of a promoted video in the video player during playback of the channel's videos.<br><br> This object can only be retrieved (or updated) by the channel's owner.
	 */
	YouTubeChannelsInvideoPromotion invideoPromotion
	
	/**
	 * The <code>auditDetails</code> object encapsulates channel data that a multichannel network (MCN) would evaluate while determining whether to accept or reject a particular channel. Note that any API request that retrieves this resource part must provide an authorization token that contains the <code>https://www.googleapis.com/auth/youtubepartner-channel-audit</code> scope. In addition, any token that uses that scope must be revoked when the MCN decides to accept or reject the channel or within two weeks of the date that the token was issued.
	 */
	YouTubeChannelsAuditDetails auditDetails
	
	/**
	 * The <code>contentOwnerDetails</code> object encapsulates channel data that is relevant for YouTube Partners linked with the channel.
	 */
	YouTubeChannelsContentOwnerDetails contentOwnerDetails
	
}

@Resource
class YouTubeChannelsSnippet {
	/**
	 * The channel's title.
	 */
	String title
	
	/**
	 * The channel's description. The property's value has a maximum length of 1000 characters.
	 */
	String description
	
	/**
	 * The date and time that the channel was created. The value is specified in <a href="//www.w3.org/TR/NOTE-datetime">ISO 8601</a> (<code>YYYY-MM-DDThh:mm:ss.sZ</code>) format.
	 */
	@WithConverter(YouTubeDateConverter) Date publishedAt
	
	/**
	 * A map of thumbnail images associated with the channel. For each object in the map, the key is the name of the thumbnail image, and the value is an object that contains other information about the thumbnail.<br/><br/>Valid key values are:
	 <ul>
	  <li><code>default</code> – The default thumbnail image for this resource. The default thumbnail for a video – or a resource that refers to a video, such as a playlist item or search result – is 120px wide and 90px tall. The default thumbnail for a channel is 88px wide and 88px tall.</li>
	  <li><code>medium</code> – A higher resolution version of the thumbnail image. For a video (or a resource that refers to a video), this image is 320px wide and 180px tall. For a channel, this image is 240px wide and 240px tall.</li>
	  <li><code>high</code> – A high resolution version of the thumbnail image. For a video (or a resource that refers to a video), this image is 480px wide and 360px tall. For a channel, this image is 800px wide and 800px tall.</li>
	 </ul>
	 */
	Map<String, YouTubeChannelsSnippetThumbnails> thumbnails
	
	/**
	 * The country with which the channel is associated. To set this property's value, update the value of the <code><a href="#brandingSettings.channel.country">brandingSettings.channel.country</a></code> property.
	 */
	String country
	
}

@Resource
class YouTubeChannelsSnippetThumbnails {
	/**
	 * The image's URL.
	 */
	String url
	
	/**
	 * The image's width.
	 */
	int width
	
	/**
	 * The image's height.
	 */
	int height
	
}

@Resource
class YouTubeChannelsContentDetails {
	/**
	 * The <code>relatedPlaylists</code> object is a map that identifies playlists associated with the channel, such as the channel's uploaded videos or favorite videos. You can retrieve any of these playlists using the <code><a href="/youtube/v3/docs/playlists/list">playlists.list</a></code> method.
	 */
	YouTubeChannelsContentDetailsRelatedPlaylists relatedPlaylists
	
	/**
	 * The <code>googlePlusUserId</code> object identifies the Google+ profile ID associated with this channel.
	 */
	String googlePlusUserId
	
}

@Resource
class YouTubeChannelsContentDetailsRelatedPlaylists {
	/**
	 * The ID of the playlist that contains the channel's liked videos. Use the <code><a href="/youtube/v3/docs/playlistItems/insert">playlistItems.insert</a></code> and <code><a href="/youtube/v3/docs/playlistItems/delete">playlistItems.delete</a></code> to add or remove items from that list.
	 */
	String likes
	
	/**
	 * The ID of the playlist that contains the channel's favorite videos. Use the <code><a href="/youtube/v3/docs/playlistItems/insert">playlistItems.insert</a></code> and <code><a href="/youtube/v3/docs/playlistItems/delete">playlistItems.delete</a></code> to add or remove items from that list.
	 */
	String favorites
	
	/**
	 * The ID of the playlist that contains the channel's uploaded videos. Use the <code><a href="/youtube/v3/docs/videos/insert">videos.insert</a></code> method to upload new videos and the <code><a href="/youtube/v3/docs/videos/delete">videos.delete</a></code> method to delete previously uploaded videos.
	 */
	String uploads
	
	/**
	 * The ID of the channel's watch history. Use the <code><a href="/youtube/v3/docs/playlistItems/insert">playlistItems.insert</a></code> and <code><a href="/youtube/v3/docs/playlistItems/delete">playlistItems.delete</a></code> to add or remove items from that list.
	 */
	String watchHistory
	
	/**
	 * The ID of channel's watch later playlist. Use the <code><a href="/youtube/v3/docs/playlistItems/insert">playlistItems.insert</a></code> and <code><a href="/youtube/v3/docs/playlistItems/delete">playlistItems.delete</a></code> to add or remove items from that list.
	 */
	String watchLater
	
}

@Resource
class YouTubeChannelsStatistics {
	/**
	 * The number of times the channel has been viewed.
	 */
	long viewCount
	
	/**
	 * The number of comments for the channel.
	 */
	long commentCount
	
	/**
	 * The number of subscribers that the channel has.
	 */
	long subscriberCount
	
	/**
	 * Indicates whether the channel's subscriber count is publicly visible.
	 */
	boolean hiddenSubscriberCount
	
	/**
	 * The number of videos uploaded to the channel.
	 */
	long videoCount
	
}

@Resource
class YouTubeChannelsTopicDetails {
	/**
	 * A list of Freebase topic IDs associated with the channel. You can retrieve information about each topic using the <a href="http://wiki.freebase.com/wiki/Topic_API">Freebase Topic API</a>.
	 */
	List<String> topicIds
	
}

@Resource
class YouTubeChannelsStatus {
	/**
	 * Privacy status of the channel.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>private</code></li> 
	  <li><code>public</code></li> 
	  <li><code>unlisted</code></li> 
	 </ul>
	 */
	String privacyStatus
	
	/**
	 * Indicates whether the channel data identifies a user that is already linked to either a YouTube username or a Google+ account. A user that has one of these links already has a public YouTube identity, which is a prerequisite for several actions, such as uploading videos.
	 */
	boolean isLinked
	
	/**
	 * Indicates whether the channel is eligible to upload videos that are more than 15 minutes long. This property is only returned if the channel owner authorized the API request. See the <a href="https://support.google.com/youtube/answer/71673">YouTube Help Center</a> for more information about this feature.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>allowed</code> – This channel can upload videos that are more than 15 minutes long.</li> 
	  <li><code>disallowed</code> – This channel is not able or eligible to upload videos that are more than 15 minutes long. A channel is only eligible to upload long videos if it is in good standing based on <a href="http://www.youtube.com/t/community_guidelines">YouTube Community Guidelines</a> and it does not have any worldwide Content ID blocks on its content.<br><br>After the channel owner resolves the issues that are preventing the channel from uploading longer videos, the channel will revert to either the <code>allowed</code> or <code>eligible</code> state.</li> 
	  <li><code>eligible</code> – This channel is eligible to upload videos that are more than 15 minutes long. However, the channel owner must first enable the ability to upload longer videos at <a href="https://www.youtube.com/verify">https://www.youtube.com/verify</a>. See the <a href="https://support.google.com/youtube/answer/71673">YouTube Help Center</a> for more detailed information about this feature.</li> 
	 </ul>
	 */
	String longUploadsStatus
	
}

@Resource
class YouTubeChannelsBrandingSettings {
	/**
	 * The <code>channel</code> object encapsulates branding properties of the channel page.
	 */
	YouTubeChannelsBrandingSettingsChannel channel
	
	/**
	 * The <code>watch</code> object encapsulates branding properties of the watch pages for the channel's videos.
	 */
	YouTubeChannelsBrandingSettingsWatch watch
	
	/**
	 * The <code>image</code> object encapsulates information about images that display on the channel's channel page or video watch pages.
	 */
	YouTubeChannelsBrandingSettingsImage image
	
	/**
	 * The <code>hints</code> object encapsulates additional branding properties.
	 */
	List<YouTubeChannelsBrandingSettingsHints> hints
	
}

@Resource
class YouTubeChannelsBrandingSettingsChannel {
	/**
	 * The channel's title. The title has a maximum length of 30 characters.
	 */
	String title
	
	/**
	 * The channel description, which appears in the channel information box on your channel page. The property's value has a maximum length of 1000 characters.
	 */
	String description
	
	/**
	 * Keywords associated with your channel. The value is a comma-separated list of strings.
	 */
	String keywords
	
	/**
	 * The content tab that users should display by default when viewers arrive at your channel page.
	 */
	String defaultTab
	
	/**
	 * The ID for a <a href="http://www.google.com/analytics/index.html">Google Analytics account</a> that you want to use to track and measure traffic to your channel.
	 */
	String trackingAnalyticsAccountId
	
	/**
	 * This setting determines whether user-submitted comments left on the channel page need to be approved by the channel owner to be publicly visible. The default value is <code>false</code>.
	 */
	boolean moderateComments
	
	/**
	 * This setting indicates whether YouTube should show an algorithmically generated list of related channels on your channel page.
	 */
	boolean showRelatedChannels
	
	/**
	 * This setting indicates whether the channel page should display content in a browse or feed view. For example, the browse view might display separate sections for uploaded videos, playlists, and liked videos. The feed view, on the other hand, displays the channel's <a href="https://developers.google.com/youtube/v3/docs/activities/list">activity feed</a>.
	 */
	boolean showBrowseView
	
	/**
	 * The title that displays above the featured channels module. The title has a maximum length of 30 characters.
	 */
	String featuredChannelsTitle
	
	/**
	 * A list of up to 100 channels that you would like to link to from the featured channels module. The property value is a list of YouTube channel ID values, each of which uniquely identifies a channel.
	 */
	List<String> featuredChannelsUrls
	
	/**
	 * The video that should play in the featured video module in the channel page's browse view for unsubscribed viewers. Subscribed viewers may see a different video that highlights more recent channel activity.<br><br> If specified, the property's value must be the YouTube video ID of a public or unlisted video that is owned by the channel owner.
	 */
	String unsubscribedTrailer
	
	/**
	 * A prominent color that complements the channel's content.
	 */
	String profileColor
	
	/**
	 * The country with which the channel is associated. Update this property to set the value of the <code><a href="#snippet.country">snippet.country</a></code> property.
	 */
	String country
	
}

@Resource
class YouTubeChannelsBrandingSettingsWatch {
	/**
	 * The background color for the video watch page's branded area.
	 */
	String textColor
	
	/**
	 * The text color for the video watch page's branded area.
	 */
	String backgroundColor
	
	/**
	 * <b>Note:</b> This property has been deprecated. The API returns an error if you attempt to set its value.
	 */
	String featuredPlaylistId
	
}

@Resource
class YouTubeChannelsBrandingSettingsImage {
	/**
	 * The URL for the banner image shown on the channel page on the YouTube website. The image is 1060px by 175px.
	 */
	String bannerImageUrl
	
	/**
	 * The URL for the banner image shown on the channel page in mobile applications. The image is 640px by 175px.
	 */
	String bannerMobileImageUrl
	
	/**
	 * The URL for the image that appears above the video player. This is a 25-pixel-high image with a flexible width that cannot exceed 170 pixels. If you do not provide this image, your channel name will appear instead of an image.
	 */
	String watchIconImageUrl
	
	/**
	 * The URL for a 1px by 1px tracking pixel that can be used to collect statistics for views of the channel or video pages.
	 */
	String trackingImageUrl
	
	/**
	 * The URL for a low-resolution banner image that displays on the channel page in tablet applications. The image's maximum size is 1138px by 188px.
	 */
	String bannerTabletLowImageUrl
	
	/**
	 * The URL for a banner image that displays on the channel page in tablet applications. The image is 1707px by 283px.
	 */
	String bannerTabletImageUrl
	
	/**
	 * The URL for a high-resolution banner image that displays on the channel page in tablet applications. The image's maximum size is 2276px by 377px.
	 */
	String bannerTabletHdImageUrl
	
	/**
	 * The URL for an extra-high-resolution banner image that displays on the channel page in tablet applications. The image's maximum size is 2560px by 424px.
	 */
	String bannerTabletExtraHdImageUrl
	
	/**
	 * The URL for a low-resolution banner image that displays on the channel page in mobile applications. The image's maximum size is 320px by 88px.
	 */
	String bannerMobileLowImageUrl
	
	/**
	 * The URL for a medium-resolution banner image that displays on the channel page in mobile applications. The image's maximum size is 960px by 263px.
	 */
	String bannerMobileMediumHdImageUrl
	
	/**
	 * The URL for a high-resolution banner image that displays on the channel page in mobile applications. The image's maximum size is 1280px by 360px.
	 */
	String bannerMobileHdImageUrl
	
	/**
	 * The URL for a very high-resolution banner image that displays on the channel page in mobile applications. The image's maximum size is 1440px by 395px.
	 */
	String bannerMobileExtraHdImageUrl
	
	/**
	 * The URL for an extra-high-resolution banner image that displays on the channel page in television applications. The image's maximum size is 2120px by 1192px.
	 */
	String bannerTvImageUrl
	
	/**
	 * The URL for a low-resolution banner image that displays on the channel page in television applications. The image's maximum size is 854px by 480px.
	 */
	String bannerTvLowImageUrl
	
	/**
	 * The URL for a medium-resolution banner image that displays on the channel page in television applications. The image's maximum size is 1280px by 720px.
	 */
	String bannerTvMediumImageUrl
	
	/**
	 * The URL for a high-resolution banner image that displays on the channel page in television applications. The image's maximum size is 1920px by 1080px.
	 */
	String bannerTvHighImageUrl
	
	/**
	 * <strong>Note:</strong> This property is only used in <code><a href="/youtube/v3/docs/channels/update">channels.update</a></code> requests.<br><br> This property specifies the location of the banner image that YouTube will use to generate the various banner image sizes for a channel. To obtain the URL banner image's external URL, you must first upload the channel banner image that you want to use by calling the <code><a href="/youtube/v3/docs/channelBanners/insert">channelBanners.insert</a></code> method.
	 */
	String bannerExternalUrl
	
}

@Resource
class YouTubeChannelsBrandingSettingsHints {
	/**
	 * A property.
	 */
	String property
	
	/**
	 * The property's value.
	 */
	String value
	
}

@Resource
class YouTubeChannelsInvideoPromotion {
	/**
	 * The <code>defaultTiming</code> object identifies the channel's default timing settings for when a promoted item will display during a video playback. These default settings can be overriden by more specific <code><a href="#invideoPromotion.items[].timing">timing</a></code> settings for any given promoted item.
	 */
	YouTubeChannelsInvideoPromotionDefaultTiming defaultTiming
	
	/**
	 * The <code>position</code> object encapsulates information about the spatial position within the video where the promoted item will be displayed.
	 */
	YouTubeChannelsInvideoPromotionPosition position
	
	/**
	 * The list of promoted items in the order that they will display across different playbacks to the same viewer. Note that you can typically only set one promoted item for your channel. If you try to insert too many promoted items, the API will return a <code>tooManyPromotedItems</code> error, which has an HTTP <code>400</code> status code.
	 */
	List<YouTubeChannelsInvideoPromotionItems> items
	
	/**
	 * Indicates whether the channel's promotional campaign uses "smart timing." This feature attempts to show promotions at a point in the video when they are more likely to be clicked and less likely to disrupt the viewing experience. This feature also picks up a single promotion to show on each video.
	 */
	boolean useSmartTiming
	
}

@Resource
class YouTubeChannelsInvideoPromotionDefaultTiming {
	/**
	 * The timing method that determines when the promoted item is inserted during the video playback. If the value is <code>offsetFromStart</code>, then the <code>offsetMs</code> field represents an offset from the start of the video. If the value is <code>offsetFromEnd</code>, then the <code>offsetMs</code> field represents an offset from the end of the video.
	 */
	String type
	
	/**
	 * The time offset, specified in milliseconds, that determines when the promoted item appears during video playbacks. The <code>type</code> property's value determines whether the offset is measured from the start or end of the video.
	 */
	long offsetMs
	
	/**
	 * Defines the duration in milliseconds for which the promotion should be displayed. If missing, the client should use the default.
	 */
	long durationMs
	
}

@Resource
class YouTubeChannelsInvideoPromotionPosition {
	/**
	 * The manner in which the promoted item is positioned in the video player.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>corner</code></li> 
	 </ul>
	 */
	String type
	
	/**
	 * The corner of the player where the promoted item will appear.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>bottomLeft</code></li> 
	  <li><code>bottomRight</code></li> 
	  <li><code>topLeft</code></li> 
	  <li><code>topRight</code></li> 
	 </ul>
	 */
	String cornerPosition
	
}

@Resource
class YouTubeChannelsInvideoPromotionItems {
	/**
	 * Identifies the promoted item.
	 */
	YouTubeChannelsInvideoPromotionItemsId id
	
	/**
	 * The time during a video playback when the promoted item will display. These timing settings override the channel's default timing settings.
	 */
	YouTubeChannelsInvideoPromotionItemsTiming timing
	
	/**
	 * A custom message to display for this promotion. This field is currently ignored unless the promoted item is a website. The property value has a maximum length of 40 characters.
	 */
	String customMessage
	
	/**
	 * Indicates whether the content owner's name will be shown when displaying the promotion. This field can only be set if the API request that sets the value is being made on the content owner's behalf. See the <code><a href="/youtube/v3/docs/channels/update#onBehalfOfContentOwner">onBehalfOfContentOwner</a></code> parameter for more information.
	 */
	boolean promotedByContentOwner
	
}

@Resource
class YouTubeChannelsInvideoPromotionItemsId {
	/**
	 * The promoted item's type.<br><br>Valid values for this property are: 
	 <ul>
	  <li><code>video</code></li>
	  <li><code>website</code></li> 
	  <li><code>recentUpload</code></li>
	 </ul>
	 */
	String type
	
	/**
	 * If the promoted item represents a video, then this value is present and identifies the YouTube ID that YouTube assigned to identify that video. This field is only present if the <code>type</code> property's value is <code>video</code>.
	 */
	String videoId
	
	/**
	 * If the promoted item represents a website, this field represents the url pointing to the website. This field will be present only if <code>type</code> has the value <code>website</code>.<br><br> Links can be to associated websites, merchant sites, or social networking sites. See the YouTube Help Center instructions for associated websites and merchant sites for more information about enabling links for your content.<br><br> By adding promotional links, you agree that those links will not be used to redirect traffic to unauthorized sites and that those links will comply with <a href="https://support.google.com/adwordspolicy/bin/answer.py?answer=54818">AdWords policies</a>, <a href="https://support.google.com/youtube/answer/188570?topic=30084">YouTube ad policies</a>, <a href="http://www.youtube.com/t/community_guidelines">YouTube Community Guidelines</a> and <a href="http://www.youtube.com/t/terms">YouTube Terms of Service</a>.
	 */
	String websiteUrl
	
	/**
	 * If the <code>invideoPromotion.items[].id.type</code> property's value is <code>recentUpload</code>, then this field identifies the channel for which the most recently uploaded video will be promoted. By default, the channel is the same one for which the in-video promotion data is set. However, you can promote the most recently uploaded video from another channel by setting this property's value to the channel ID for that channel.
	 */
	String recentlyUploadedBy
	
}

@Resource
class YouTubeChannelsInvideoPromotionItemsTiming {
	/**
	 * The timing method that determines when the promoted item is inserted during the video playback. If the value is <code>offsetFromStart</code>, then the <code>offsetMs</code> field represents an offset from the start of the video. If the value is <code>offsetFromEnd</code>, then the <code>offsetMs</code> field represents an offset from the end of the video.
	 */
	String type
	
	/**
	 * The time offset, specified in milliseconds, that determines when the promoted item appears during video playbacks. The <code>type</code> property's value determines whether the offset is measured from the start or end of the video.
	 */
	long offsetMs
	
	/**
	 * Defines the duration in milliseconds for which the promotion should be displayed. If missing, the client should use the default.
	 */
	long durationMs
	
}

@Resource
class YouTubeChannelsAuditDetails {
	/**
	 * This field indicates whether there are any issues with the channel. Currently, this field represents the result of the logical <code>AND</code> operation over the <code>communityGuidelinesGoodStanding</code>, <code>copyrightStrikesGoodStanding</code>, and <code>contentIdClaimsGoodStanding</code> properties, meaning that this property has a value of <code>true</code> if all of those other properties also have a value of <code>true</code>. However, this property will have a value of <code>false</code> if any of those properties has a value of <code>false</code>. Note, however, that the methodology used to set this property's value is subject to change.
	 */
	boolean overallGoodStanding
	
	/**
	 * Indicates whether the channel respects YouTube's community guidelines.
	 */
	boolean communityGuidelinesGoodStanding
	
	/**
	 * Indicates whether the channel has any copyright strikes.
	 */
	boolean copyrightStrikesGoodStanding
	
	/**
	 * Indicates whether the channel has any unresolved claims.
	 */
	boolean contentIdClaimsGoodStanding
	
}

@Resource
class YouTubeChannelsContentOwnerDetails {
	/**
	 * The ID of the content owner linked to the channel.
	 */
	String contentOwner
	
	/**
	 * The date and time of when the channel was linked to the content owner. The value is specified in <a href="//www.w3.org/TR/NOTE-datetime">ISO 8601</a> (<code>YYYY-MM-DDThh:mm:ss.sZ</code>) format.
	 */
	@WithConverter(YouTubeDateConverter) Date timeLinked
	
}


