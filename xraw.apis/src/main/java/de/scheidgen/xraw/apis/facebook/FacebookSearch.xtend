package de.scheidgen.xraw.apis.facebook

import de.scheidgen.xraw.annotations.JSON
import de.scheidgen.xraw.annotations.Parameter
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response

@Request(url="https://graph.facebook.com/search", parameters=#[@Parameter(name="type", value="page")], response=@Response(resourceType=FacebookPageSearchResult))
class FacebookPageSearch {
	String q
	String fields
	int limit
}

@JSON class FacebookPageSearchResult extends FacebookEdge<FacebookPage> {
	
}