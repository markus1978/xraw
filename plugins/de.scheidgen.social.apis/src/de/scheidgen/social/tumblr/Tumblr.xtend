package de.scheidgen.social.tumblr

import de.scheidgen.social.core.annotations.Directory
import de.scheidgen.social.tumblr.blog.Info

@Directory
class Tumblr {
	Blog blog
}

@Directory
class Blog {
	Info info	
}
