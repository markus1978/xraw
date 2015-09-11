package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.youtube.YouTube
import de.scheidgen.xraw.script.XRawScript

class YouTubeSearchExample {
	
	static def void main(String[] args) {		
		val youtube = XRawScript::get("data/store.xmi", "markus", YouTube)
		
		println(youtube.search.list.part("snippet").q("until dawn markiplier").xResult.pageInfo.totalResults)
	}
}