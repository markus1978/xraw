package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.twitch.Twitch
import de.scheidgen.xraw.script.XRawScript

class TwitchExample {
	
	static def void main(String[] args) {		
		val twitch = XRawScript::get("data/store.xmi", "markus", Twitch)
		
		val channels = twitch.channelSearch.q("markiplier").limit(5).xCheck.xResult.channels		
		
		println(channels.map[it.name].join(", "))		
	}
}