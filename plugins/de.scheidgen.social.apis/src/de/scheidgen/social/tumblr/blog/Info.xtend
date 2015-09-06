package de.scheidgen.social.tumblr.blog

import de.scheidgen.social.annotations.Request
import de.scheidgen.social.annotations.ResponseContainer
import de.scheidgen.social.annotations.UrlReplace
import de.scheidgen.social.tumblr.response.TumblrBlog
import org.scribe.model.Verb

@Request(method=Verb.GET,url="https://api.tumblr.com/v2/blog/{base-hostname}/info",returnType=TumblrBlog)
@ResponseContainer("response/blog")
class Info {
	@UrlReplace("{base-hostname}") String baseHostname
}