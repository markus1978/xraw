package de.scheidgen.social.tumblr

import de.scheidgen.social.annotations.Directory
import de.scheidgen.social.tumblr.blog.Info
import de.scheidgen.social.annotations.Service
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
