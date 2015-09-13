package de.scheidgen.xraw.apis.youtube.resources

import de.scheidgen.xraw.apis.youtube.YouTubeDateConverter
import de.scheidgen.xraw.json.JSON
import de.scheidgen.xraw.json.WithConverter
import java.util.Date

@JSON
class YouTubeSearchResult extends AbstractYouTubeResource {
	/**
	 * The id object contains information that can be used to uniquely identify the resource that matches the search request.
	 */
	YouTubeSearchResultId id
	
	/** 
	 * The snippet object contains basic details about a search result, such as its title or description. For example, if the search result is a video, then the title will be the video's title and the description will be the video's description. 
	 */	
  	YouTubeSearchSnippet snippet
}

@JSON
class YouTubeSearchResultId {
	/**
	 * The type of the API resource.
	 */
	String kind
	
	/**
	 * If the id.type property's value is youtube#video, then this property will be present and its value will contain the ID that YouTube uses to uniquely identify a video that matches the search query.
	 */
    String videoId
    
    /**
	 * If the id.type property's value is youtube#channel, then this property will be present and its value will contain the ID that YouTube uses to uniquely identify a channel that matches the search query.
	 */
    String channelId
    
    /**
     * If the id.type property's value is youtube#playlist, then this property will be present and its value will contain the ID that YouTube uses to uniquely identify a playlist that matches the search query.
     */
    String playlistId
}

@JSON
class YouTubeSearchSnippet {
	/**
	 * The creation date and time of the resource that the search result identifies. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format.
	 */
	@WithConverter(YouTubeDateConverter) Date publishedAt
	
	/**
	 * The value that YouTube uses to uniquely identify the channel that published the resource that the search result identifies.
	 */
    String channelId
    
    /**
     * The title of the search result.
     */
    String title
    
    /**
     * A description of the search result.
     */
    String description
    
    /** 
     * A map of thumbnail images associated with the search result. For each object in the map, the key is the name of the thumbnail image, and the value is an object that contains other information about the thumbnail.
     */    
    Object thumbnails // TODO    
    
    /**
     * The title of the channel that published the resource that the search result identifies.
     */ 
    String channelTitle
    
    /**
     * An indication of whether a video or channel resource has live broadcast content. Valid property values are upcoming, live, and none.
	 * <br/><br/>
     * For a video resource, a value of upcoming indicates that the video is a live broadcast that has not yet started, while a value of live indicates that the video is an active live broadcast. For a channel resource, a value of upcoming indicates that the channel has a scheduled broadcast that has not yet started, while a value of live indicates that the channel has an active live broadcast.
     */
    String liveBroadcastContent
}