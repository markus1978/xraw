package de.scheidgen.social.test

import de.scheidgen.social.tumblr.Tumblr
import de.scheidgen.social.script.SocialScript

class TumblrTest {
	
	static def void main(String[] args) {
		val tumblr = SocialScript::createWithStore("data/store.xmi").serviceWithLogin(Tumblr, "markus")
		
		val response = tumblr.blog.info.baseHostname("cubemonstergames.tumblr.com").send
		println(response.description)		
	}
}