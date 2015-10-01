package de.scheidgen.xraw.apis.facebook

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.json.JSON
import de.scheidgen.xraw.annotations.UrlReplace

@Request(url="https://graph.facebook.com/v2.4/{id}", response=@Response(resourceType=FacebookPage))
class FacebookPages {
	@UrlReplace("{id}") String id
	String fields
}

@JSON class FacebookPage extends FacebookObject {
	// fields
	String id
	int likes
	String about
	String name
	String website
	
	// edges
	FacebookEdge<FacebookPost> posts
}