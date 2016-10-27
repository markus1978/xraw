package de.scheidgen.xraw.apis.tumblr

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.apis.tumblr.blog.Info

@Directory @Service class Tumblr {
	Blog blog
	TumblrTagged tagged
}

@Directory class Blog {
	Info info	
}
