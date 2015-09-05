package de.scheidgen.social.tumblr

import de.scheidgen.social.core.SocialService
import de.scheidgen.social.core.annotations.AbstractApi
import de.scheidgen.social.tumblr.blog.Info

class Tumblr extends AbstractApi {
	
	static class Blog extends AbstractApi {
			
		protected new(SocialService service) {
			super(service)
		}
		
		def getInfo() {
			return Info.create(service)
		}		
	}
	
	val Blog blog

	static def get(SocialService service) {
		return new Tumblr(service)
	}
	
	protected new(SocialService service) {
		super(service)
		this.blog = new Blog(service)
	}
	
	def getBlog() {
		return this.blog
	}

}