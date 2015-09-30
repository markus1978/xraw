package de.scheidgen.xraw.apis.facebook

import de.scheidgen.xraw.json.JSON

@JSON class FacebookPost extends FacebookObject {
	
	String link
	
	// edges
	FacebookEdge<FacebookComment> comments
}