package de.scheidgen.social.test

import de.scheidgen.social.tumblr.Tumblr

class TumblrTest {
	
	static def void main(String[] args) {
		val profile = SocialUtil::openProfile
		val tumblr = Tumblr.create(SocialUtil::getTumblrService(profile))
		
		val response = tumblr.blog.info.baseHostname("cubemonstergames.tumblr.com").send
		println(response.description)		
	}
}