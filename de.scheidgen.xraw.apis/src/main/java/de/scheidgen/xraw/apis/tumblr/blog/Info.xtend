package de.scheidgen.xraw.apis.tumblr.blog

import de.scheidgen.xraw.apis.tumblr.response.TumblrBlog
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.ResponseContainer
import de.scheidgen.xraw.annotations.UrlReplace
import org.scribe.model.Verb

@Request(method=Verb.GET,url="https://api.tumblr.com/v2/blog/{base-hostname}/info",returnType=TumblrBlog)
@ResponseContainer("response/blog")
class Info {
	@UrlReplace("{base-hostname}") String baseHostname
}