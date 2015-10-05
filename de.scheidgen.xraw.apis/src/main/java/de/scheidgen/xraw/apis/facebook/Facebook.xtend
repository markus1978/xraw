package de.scheidgen.xraw.apis.facebook

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration

@Directory @Service class Facebook {
	FacebookPages pages
	FacebookPosts posts
	
	FacebookSearch search

	override protected createService(XRawHttpServiceConfiguration httpServiceConfig) {
		return new FacebookOAuth2Service(httpServiceConfig)
	}
}

@Directory class FacebookSearch {
	FacebookPageSearch page
}