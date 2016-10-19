package de.scheidgen.xraw.apis.tumblr

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.tumblr.response.TumblrBlog

@Request(url="https://api.tumblr.com/v2/tagged", response=@Response(resourceType=TumblrBlog,isList=true,resourceKey="resource"))
class TumblrTagged {
	String tag
	long before
	int limit
	String filter
}