package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.tumblr.Tumblr
import de.scheidgen.xraw.XRawScript

class TumblrExample {
	
	static def void main(String[] args) {
		val tumblr = XRawScript::createWithStore("data/store.xmi").serviceWithLogin(Tumblr, "markus")
		
		val response = tumblr.blog.info.baseHostname("cubemonstergames.tumblr.com").send
		println(response.description)		
	}
}