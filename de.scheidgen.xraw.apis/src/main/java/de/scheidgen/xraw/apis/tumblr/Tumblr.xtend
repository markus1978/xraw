package de.scheidgen.xraw.apis.tumblr

import de.scheidgen.xraw.apis.tumblr.blog.Info
import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import org.scribe.builder.api.TumblrApi

@Directory
@Service(TumblrApi)
class Tumblr {
	Blog blog
}

@Directory
class Blog {
	Info info	
}
