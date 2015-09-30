package de.scheidgen.xraw.apis.facebook

import de.scheidgen.xraw.json.JSON
import java.util.List

@JSON class FacebookComment extends FacebookObject {
	
}


@JSON class FacebookEdge<Type extends FacebookObject> {	
	List<Type> data
}

@JSON class FacebookObject {
	
}