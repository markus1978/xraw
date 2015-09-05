package de.scheidgen.social.twitter

import de.scheidgen.social.core.SocialService
import de.scheidgen.social.core.annotations.AbstractApi
import de.scheidgen.social.twitter.search.Tweets
import de.scheidgen.social.twitter.statuses.Show
import de.scheidgen.social.twitter.statuses.UserTimeline

class Twitter extends AbstractApi {
	
	static class Statuses extends AbstractApi {
			
		protected new(SocialService service) {
			super(service)
		}
		
		def getUserTimeline() {
			return UserTimeline.create(service)
		}		
		
		def getShow() {
			return Show.create(service)
		}
	}
	
	static class Search extends AbstractApi {
		
		protected new(SocialService service) {
			super(service)
		}
		
		def getTweets() {
			return Tweets.create(service)
		}
		
	}

	val Statuses statuses
	val Search search

	static def get(SocialService service) {
		return new Twitter(service)
	}
	
	protected new(SocialService service) {
		super(service)
		this.statuses = new Statuses(service)
		this.search = new Search(service)
	}
	
	def getStatuses() {
		return this.statuses
	}
	
	def getSearch() {
		return this.search
	}

}