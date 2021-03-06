package de.scheidgen.xraw.apis.twitch

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration

@Directory @Service class Twitch {
	Channel channel
	ChannelPanels channelPanels
	ChannelVideos channelVideos
	ChannelSearch channelSearch
	Video video
}