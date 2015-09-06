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