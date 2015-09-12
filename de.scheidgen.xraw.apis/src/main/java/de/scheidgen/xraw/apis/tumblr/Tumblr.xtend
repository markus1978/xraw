package de.scheidgen.xraw.apis.tumblr

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.apis.tumblr.blog.Info
import de.scheidgen.xraw.http.ScribeOAuth1Service
import org.scribe.builder.api.TumblrApi
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration

@Directory @Service class Tumblr {
	Blog blog
	
	override protected createService(XRawHttpServiceConfiguration httpServiceConfig) {
		return new ScribeOAuth1Service(TumblrApi, httpServiceConfig)
	}
}

@Directory class Blog {
	Info info	
}
