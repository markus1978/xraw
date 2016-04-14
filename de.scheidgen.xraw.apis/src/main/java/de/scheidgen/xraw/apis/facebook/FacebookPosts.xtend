package de.scheidgen.xraw.apis.facebook

import de.scheidgen.xraw.annotations.JSON
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.UrlReplace

@Request(url="https://graph.facebook.com/v2.4/{id}", response=@Response(resourceType=FacebookPost))
class FacebookPosts {
	@UrlReplace("{id}") String id
	String fields
}

@JSON class FacebookPost extends FacebookObject {
	
	String id
	String link
	FacebookProfile from
	
	// edges
	FacebookEdge<FacebookComment> comments
}