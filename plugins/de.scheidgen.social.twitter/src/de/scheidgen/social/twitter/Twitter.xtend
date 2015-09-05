package de.scheidgen.social.twitter

import de.scheidgen.social.core.SocialService
import de.scheidgen.social.twitter.statuses.UserTimeline

class AbstractApi {
	protected val SocialService service;
	protected new(SocialService service) {
		this.service = service;
	}
}

class Twitter extends AbstractApi {
	
	static class Statuses extends AbstractApi {
			
		protected new(SocialService service) {
			super(service)
		}
		
		def getUserTimeline() {
			return UserTimeline.create(service)
		}		
	}

	val Statuses statuses

	static def get(SocialService service) {
		return new Twitter(service)
	}
	
	protected new(SocialService service) {
		super(service)
		this.statuses = new Statuses(service)
	}
	
	def getStatuses() {
		return this.statuses
	}

}