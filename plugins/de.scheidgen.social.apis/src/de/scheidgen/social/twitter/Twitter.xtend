package de.scheidgen.social.twitter

import de.scheidgen.social.core.annotations.Directory
import de.scheidgen.social.twitter.statuses.Show
import de.scheidgen.social.twitter.statuses.UserTimeline
import de.scheidgen.social.twitter.search.Tweets

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