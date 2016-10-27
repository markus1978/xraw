package de.scheidgen.xraw.apis.twitch

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.UrlReplace

@Request(url="https://api.twitch.tv/kraken/channels/{channel}", response=@Response(resourceType=TwitchChannel))
class Channel {
	@UrlReplace("{channel}") String channelName
}

@Request(url="https://api.twitch.tv/api/channels/{channel}/panels", response=@Response(resourceType=TwitchPanel,isList=true))
class ChannelPanels {
	@UrlReplace("{channel}") String channelName
}

@Request(url="https://api.twitch.tv/kraken/channels/{channel}/videos", response=@Response(resourceType=TwitchVideoList))
class ChannelVideos {
	@UrlReplace("{channel}") String channelName
	int limit
	int offset
	boolean broadcasts
	boolean hls
}