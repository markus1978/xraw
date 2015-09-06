package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.tumblr.Tumblr
import de.scheidgen.xraw.SocialScript

class TumblrExample {
	
	static def void main(String[] args) {
		val tumblr = SocialScript::createWithStore("data/store.xmi").serviceWithLogin(Tumblr, "markus")
		
		val response = tumblr.blog.info.baseHostname("cubemonstergames.tumblr.com").send
		println(response.description)		
	}
}