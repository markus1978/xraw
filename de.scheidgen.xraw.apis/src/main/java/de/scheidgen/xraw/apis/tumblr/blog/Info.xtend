package de.scheidgen.xraw.apis.tumblr.blog

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.UrlReplace
import de.scheidgen.xraw.apis.tumblr.response.TumblrBlog

@Request(
	url="https://api.tumblr.com/v2/blog/{base-hostname}/info",
	response=@Response(		
		resourceType=TumblrBlog,
		resourceKey="blog"
	)
)
class Info {
	@UrlReplace("{base-hostname}") String baseHostname
}