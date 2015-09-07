package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.Name

@Response
class TwitterFriendship {
	String name
    String screen_name
    @Name("id_str") String id
	TwitterConnections[] connections
}

enum TwitterConnections {
	following, following_requested, followed_by, none, blocking, muting
}