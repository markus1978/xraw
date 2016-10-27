package de.scheidgen.xraw.apis.facebook

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service

@Directory @Service class Facebook {
	FacebookPages pages
	FacebookPosts posts
	
	FacebookSearch search
}

@Directory class FacebookSearch {
	FacebookPageSearch page
}