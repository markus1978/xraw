package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.twitch.Twitch
import de.scheidgen.xraw.script.XRawScript
import de.scheidgen.xraw.oauth.TwitchOAuth2Service

class TwitchExample {
	
	static def void main(String[] args) {		
		val twitch = XRawScript::get("data/store", "markus", Twitch) [new TwitchOAuth2Service(it)]
		
		val channels = twitch.channelSearch.q("markiplier").limit(5).xCheck.xResult.channels		
		val firstId = channels.findFirst[true].name
		
		println(channels.map[it.name].join(", "))
		println("First id " + firstId)
		
		val links = twitch.channelPanels.channelName(firstId).xResult.map[it.data.link]
		
		println(links.join(", "))		
	}
}