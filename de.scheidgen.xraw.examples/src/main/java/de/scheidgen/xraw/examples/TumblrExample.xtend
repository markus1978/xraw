package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.tumblr.Tumblr
import de.scheidgen.xraw.script.XRawScript

class TumblrExample {
	
	static def void main(String[] args) {
		val tumblr = XRawScript::get("data/store.xmi", "markus", Tumblr)
		
		val response = tumblr.blog.info.baseHostname("cubemonstergames.tumblr.com").xExecute.xResult
		println(response.description)
				
	}
}