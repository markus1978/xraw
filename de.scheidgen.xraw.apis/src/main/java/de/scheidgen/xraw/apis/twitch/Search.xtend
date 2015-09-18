package de.scheidgen.xraw.apis.twitch

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitch.response.TwitchChannelList

@Request(url="https://api.twitch.tv/kraken/search/channels", response=@Response(resourceType=TwitchChannelList))
class ChannelSearch {
	String q
	int limit
	int offset
}

