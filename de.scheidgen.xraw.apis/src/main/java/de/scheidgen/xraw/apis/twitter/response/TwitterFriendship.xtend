package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.annotations.JSON
import de.scheidgen.xraw.annotations.Name
import java.util.List

@JSON
class TwitterFriendship {
	String name
    String screen_name
    @Name("id_str") String id
	List<TwitterConnections> connections
}

enum TwitterConnections {
	following, following_requested, followed_by, none, blocking, muting
}