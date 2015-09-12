package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.youtube.YouTube
import de.scheidgen.xraw.script.XRawScript
import de.scheidgen.xraw.AbstractRequest
import de.scheidgen.xraw.DefaultResponse

class YouTubeSearchExample {
	
	private static def<R extends AbstractRequest<? extends DefaultResponse,?>> xCheck(R request) {
		if (!request.xResponse.successful) {
			println("Api error: " + request.xResponse.code)
			throw new RuntimeException("Abort")
		}
		return request
	}
	
	static def void main(String[] args) {		
		val youtube = XRawScript::get("data/store.xmi", "markus", YouTube)
		
		val search = youtube.search.list
			.part("snippet")
			.q("reviews mobile games")
			.relevanceLanguage("en")
//			.regionCode("US")
			.type("video")
			.order("rating")
			.xCheck
			
		if (!search.xResponse.successful) {
			println("Api error: " + search.xResponse.code)
		}
		
		println(search.xResult.pageInfo.resultsPerPage + " of " + search.xResult.pageInfo.totalResults)
		
		val channelIds = search.xResult.items.map[it.snippet.channelId]
		println(channelIds.join(", "))
		val channelList = youtube.channels.list
			.part("statistics,brandingSettings")
			.id(channelIds.join(",")).xCheck
			
		val channels = channelList.xResult.items.map[it.brandingSettings.channel]
		channels.forEach[println("[" + it.country + "/" + it.keywords + "] " + it.title + ": " + it.description); println("")]
	}
}