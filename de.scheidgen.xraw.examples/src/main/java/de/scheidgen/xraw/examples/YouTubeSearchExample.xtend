package de.scheidgen.xraw.examples

import de.scheidgen.xraw.XRawScript
import de.scheidgen.xraw.apis.youtube.YouTube

class YouTubeSearchExample {
	
	static def void main(String[] args) {		
		val youtube = XRawScript::createWithStore("data/store.xmi").serviceWithLogin(YouTube, "markus")
		
		println(youtube.search.list.part("snippet").q("until dawn markiplier").xResult.pageInfo.totalResults)
	}
}