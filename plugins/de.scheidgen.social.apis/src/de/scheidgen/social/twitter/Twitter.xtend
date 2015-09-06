package de.scheidgen.social.twitter

import de.scheidgen.social.annotations.Directory
import de.scheidgen.social.twitter.search.Tweets
import de.scheidgen.social.twitter.statuses.Show
import de.scheidgen.social.twitter.statuses.UserTimeline

@Directory
class Twitter {
	Statuses statuses
	Search search
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