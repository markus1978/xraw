package de.scheidgen.xraw.examples

import com.github.scribejava.apis.TumblrApi
import de.scheidgen.xraw.apis.tumblr.Tumblr
import de.scheidgen.xraw.http.ScribeOAuth1Service
import de.scheidgen.xraw.script.XRawScript

class TumblrExample {
	
	static def void main(String[] args) {
		val tumblr = XRawScript::get("data/store", "markus", Tumblr) [new ScribeOAuth1Service(TumblrApi.instance, it)]
		
//		val body = tumblr.blog.info.baseHostname("cubemonstergames.tumblr.com").xResponse.getJSONObject("")
//		println(body.toString(4))
//		
//		val response = tumblr.blog.info.baseHostname("cubemonstergames.tumblr.com").xExecute.xResult
//		println(response.description)
				
		val taggedResponse = tumblr.tagged.tag("markiplier").limit(3).xResponse
		println(taggedResponse.getJSONObject("").toString(4))
	}
}