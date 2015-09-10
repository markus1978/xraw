package de.scheidgen.xraw.examples

import de.scheidgen.xraw.XRawScript
import de.scheidgen.xraw.apis.youtube.YouTube
import de.scheidgen.xraw.apis.youtube.resources.YouTubeSearchListResponse
import static extension de.scheidgen.xraw.XRawIterableExtensions.*

class YouTubeSearchExample {
	
	static def void main(String[] args) {		
		val youtube = XRawScript::createWithStore("data/store.xmi").serviceWithLogin(YouTube, "markus")
		
		var YouTubeSearchListResponse result = null
		var channelIds= newArrayList
		val request = youtube.search.list.part("snippet").q("reviews games").type("channel")
		for (i:0..1) {
			request.xReset
			if (result != null) {
				request.pageToken(result.nextPageToken)
			}
			
			if (!request.xResponse.successful) {
				println(request.xResponse)
				throw new RuntimeException("")	
			}
			
			result = request.xResult	
					
			channelIds.addAll(result.items.collect[it.snippet.channelId])
		}
		
		val channels = youtube.channel.list.part("brandingSettings,statistics").id(channelIds.first(10).join(",")).xResult.items
		for (channel: channels) {
			println('''[«channel.statistics.subscriberCount»] «channel.brandingSettings.channel.title»:''')
			println(channel.brandingSettings.channel.featuredChannelsUrls.join("\n"))
			println("")
		}
	}
}