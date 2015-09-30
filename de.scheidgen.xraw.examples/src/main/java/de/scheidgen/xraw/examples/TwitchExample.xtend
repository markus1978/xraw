package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.twitch.Twitch
import de.scheidgen.xraw.script.XRawScript

class TwitchExample {
	
	static def void main(String[] args) {		
		val twitch = XRawScript::get("data/store", "markus", Twitch)
		
		val channels = twitch.channelSearch.q("markiplier").limit(5).xCheck.xResult.channels		
		val firstId = channels.findFirst[true].name
		
		println(channels.map[it.name].join(", "))
		println("First id " + firstId)
		
		val links = twitch.channelPanels.channelName(firstId).xResult.map[it.data.link]
		
		println(links.join(", "))		
	}
}