package de.scheidgen.xraw.apis.twitch

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration

@Directory @Service class Twitch {
	Channel channel
	ChannelVideos channelVideos
	ChannelSearch channelSearch
	Video video
	
	override protected createService(XRawHttpServiceConfiguration httpServiceConfig) {
		return new TwitchOAuth2Service(httpServiceConfig)
	}
}