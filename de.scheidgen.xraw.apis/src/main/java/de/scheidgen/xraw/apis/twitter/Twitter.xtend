package de.scheidgen.xraw.apis.twitter

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.apis.twitter.account.VerifyCredentials
import de.scheidgen.xraw.apis.twitter.friends.Id
import de.scheidgen.xraw.apis.twitter.friends.List
import de.scheidgen.xraw.apis.twitter.friendships.Create
import de.scheidgen.xraw.apis.twitter.friendships.Destroy
import de.scheidgen.xraw.apis.twitter.friendships.Lookup
import de.scheidgen.xraw.apis.twitter.search.Tweets
import de.scheidgen.xraw.apis.twitter.statuses.Show
import de.scheidgen.xraw.apis.twitter.statuses.UserTimeline
import de.scheidgen.xraw.apis.twitter.friendships.Outgoing
import de.scheidgen.xraw.apis.twitter.friendships.Incoming

@Directory
@Service
class Twitter {
	Statuses statuses
	Search search
	Users users
	Friends friends
	Followers followers
	Friendships friendships
	Account account
	DirectMessages direct_messages
}

@Directory
class Account {
	VerifyCredentials verifyCredentials
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
	Outgoing outgoing
	Incoming incoming
	Lookup lookup
	Destroy destroy
	Create create
	de.scheidgen.xraw.apis.twitter.friendships.Show show
}

@Directory
class Users {
	de.scheidgen.xraw.apis.twitter.users.Search search
	de.scheidgen.xraw.apis.twitter.users.Lookup lookup
	de.scheidgen.xraw.apis.twitter.users.Show show
}

@Directory
class DirectMessages {
	de.scheidgen.xraw.apis.twitter.direct_messages.Sent sent
	de.scheidgen.xraw.apis.twitter.direct_messages.Show show
	de.scheidgen.xraw.apis.twitter.direct_messages.New new_
	de.scheidgen.xraw.apis.twitter.direct_messages.Destroy destroy
}