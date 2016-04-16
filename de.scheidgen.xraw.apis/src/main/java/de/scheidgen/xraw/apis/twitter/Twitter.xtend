package de.scheidgen.xraw.apis.twitter

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.apis.twitter.friends.Id
import de.scheidgen.xraw.apis.twitter.friends.List
import de.scheidgen.xraw.apis.twitter.friendships.Create
import de.scheidgen.xraw.apis.twitter.friendships.Destroy
import de.scheidgen.xraw.apis.twitter.friendships.Lookup
import de.scheidgen.xraw.apis.twitter.search.Tweets
import de.scheidgen.xraw.apis.twitter.statuses.Show
import de.scheidgen.xraw.apis.twitter.statuses.UserTimeline
import de.scheidgen.xraw.core.AbstractRequest
import de.scheidgen.xraw.json.XObject

@Directory
@Service
class Twitter {
	Statuses statuses
	Search search
	Users users
	Friends friends
	Followers followers
	Friendships friendships
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
	Create create
}

@Directory
class Users {
	de.scheidgen.xraw.apis.twitter.users.Search search
	de.scheidgen.xraw.apis.twitter.users.Lookup lookup
	de.scheidgen.xraw.apis.twitter.users.Show show
}