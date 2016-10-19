package de.scheidgen.xraw.apis.youtube.resources

import de.scheidgen.xraw.annotations.JSON

@JSON
class AbstractYouTubeResource {
	/**
	 * Identifies the API resource's type. The value will be youtube#searchListResponse.
	 */
	String kind
	
	/**
	 * The Etag of this resource.
	 */
    Object etag
    
}