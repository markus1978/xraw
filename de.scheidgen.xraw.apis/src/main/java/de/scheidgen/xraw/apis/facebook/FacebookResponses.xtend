package de.scheidgen.xraw.apis.facebook

import de.scheidgen.xraw.annotations.JSON
import java.util.List

@JSON class FacebookComment extends FacebookObject {
	
}

@JSON class FacebookEdge<Type extends FacebookObject> {	
	List<Type> data
}

@JSON class FacebookProfile extends FacebookObject {
	String name
	String id
}

@JSON class FacebookObject {
	
}