package de.scheidgen.xraw.apis.twitter

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.apis.twitter.search.Tweets
import de.scheidgen.xraw.apis.twitter.statuses.Show
import de.scheidgen.xraw.apis.twitter.statuses.UserTimeline
import de.scheidgen.xraw.annotations.Service
import org.scribe.builder.api.TwitterApi

@Directory
@Service(TwitterApi)
class Twitter {
	Statuses statuses
	Search search
	Users users
	Friends friends
	Followers followers
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
	de.scheidgen.xraw.apis.twitter.friends.Id id
	de.scheidgen.xraw.apis.twitter.friends.List list
}

@Directory 
class Followers {
	de.scheidgen.xraw.apis.twitter.followers.Id id
	de.scheidgen.xraw.apis.twitter.followers.List list
}

@Directory
class Users {
	de.scheidgen.xraw.apis.twitter.users.Search search
	de.scheidgen.xraw.apis.twitter.users.Lookup lookup
	de.scheidgen.xraw.apis.twitter.users.Show show
}