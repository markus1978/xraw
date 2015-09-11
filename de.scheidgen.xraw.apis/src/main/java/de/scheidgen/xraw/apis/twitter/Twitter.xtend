package de.scheidgen.xraw.apis.twitter

import de.scheidgen.xraw.AbstractRequest
import de.scheidgen.xraw.AbstractResource
import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.apis.twitter.friends.Id
import de.scheidgen.xraw.apis.twitter.friends.List
import de.scheidgen.xraw.apis.twitter.friendships.Destroy
import de.scheidgen.xraw.apis.twitter.friendships.Lookup
import de.scheidgen.xraw.apis.twitter.search.Tweets
import de.scheidgen.xraw.apis.twitter.statuses.Show
import de.scheidgen.xraw.apis.twitter.statuses.UserTimeline
import org.scribe.builder.api.TwitterApi
import de.scheidgen.xraw.script.ServiceConfiguration
import de.scheidgen.xraw.http.ScribeOAuth1Service

@Directory
@Service
class Twitter {
	Statuses statuses
	Search search
	Users users
	Friends friends
	Followers followers
	Friendships friendships
	
	override protected createService(ServiceConfiguration httpServiceConfig) {
		return new ScribeOAuth1Service(TwitterApi, httpServiceConfig)
	}
	
	public static def <R extends AbstractResource> TwitterResponse safeCursor(AbstractRequest<? extends TwitterResponse, R> request, (R)=>void function) {
		var cursor = "-1"
		var continue = true
		
		while (continue && cursor != "0") {
			request.xReset
			request.xPutQueryStringParameter("cursor", cursor)
			request.xExecute
	
			if (request.xResponse.successful) {
				function.apply(request.xResult)
				cursor = request.xResult.xGetString("next_cursor")				
				continue = request.xResponse.rateLimitRemaining > 0 && cursor != null
			} else {
				continue = false				
			}
		}

		return request.xResponse		
	}
	
	public static def <E,R extends AbstractRequest<TwitterResponse, ?>> TwitterResponse safeForEach(Iterable<? extends E> iterable, (E)=>R createRequest, (R)=>void function) {
		var continue = true
		
		var R request = null
		var iterator = iterable.iterator
		while (continue && iterator.hasNext) {			
			request = createRequest.apply(iterator.next)
			request.xReset
			request.xExecute
	
			if (request.xResponse.successful) {
				function.apply(request)
				continue = request.xResponse.rateLimitRemaining > 0
			} else {
				continue = false				
			}
		}

		return request?.xResponse
	}
}

@Directory 
class Search {
	Tweets tweets
}

@Directory
class Statuses {
	Show show
	UserTimeline userTimeline
}

@Directory 
class Friends {
	Id id
	List list
}

@Directory 
class Followers {
	de.scheidgen.xraw.apis.twitter.followers.Id id
	de.scheidgen.xraw.apis.twitter.followers.List list
}

@Directory
class Friendships {
	Lookup lookup
	Destroy destroy
}

@Directory
class Users {
	de.scheidgen.xraw.apis.twitter.users.Search search
	de.scheidgen.xraw.apis.twitter.users.Lookup lookup
	de.scheidgen.xraw.apis.twitter.users.Show show
}