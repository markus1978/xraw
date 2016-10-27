package de.scheidgen.xraw.examples

import de.scheidgen.xraw.annotations.AddConstructor
import de.scheidgen.xraw.apis.youtube.YouTube
import de.scheidgen.xraw.client.core.AbstractRequest
import de.scheidgen.xraw.client.core.DefaultResponse
import de.scheidgen.xraw.oauth.GoogleOAuth2Service
import de.scheidgen.xraw.script.XRawScript
import java.util.List

import static extension de.scheidgen.xraw.client.util.XRawIterableExtensions.*

@AddConstructor
class YouTubeSearchExample {
	private static def<R extends AbstractRequest<? extends DefaultResponse,?>> xCheck(R request) {
		if (!request.xResponse.successful) {
			println("Api error: " + request.xResponse.code)
			throw new RuntimeException("Abort")
		}
		return request
	}
	
	val youtube = XRawScript::get("data/store.json", "markus", YouTube) [new GoogleOAuth2Service(it)]
	
	val String keywordStr
	val String language
	
	private def seed(int count) {
		val search = youtube.search.list
			.part("snippet")
			.q(keywordStr)
			.relevanceLanguage(language)
			.type("video")
			.order("rating")
			.videoDuration("medium")
			.maxResults(count)
			.xCheck	
	
		return search.xResult.items.map[snippet.channelId]
	}
	
	private def evaluate(List<String> channelIds) {
		val channelsList = youtube.channels.list
			.part("statistics,brandingSettings")
			.id(channelIds.join(","))
			.maxResults(50)
			.xCheck
		
		return channelsList.xResult.items.map[channel|
			val search = youtube.search.list
				.part("snippet")
				.q(keywordStr)
				.type("video")
				.videoDuration("medium")
				.channelId(channel.id)
				.order("rating")
				.maxResults(10)
				.xCheck
				
			val videoIds = search.xResult.items.map[it.id.videoId]
			val videosList = youtube.videos.list
				.part("statistics")
				.id(videoIds.join(","))
				.maxResults(10)
				.xCheck
			
			val score = videosList.xResult.items.sum[
				(statistics.viewCount*statistics.likeCount/Math.max(1,statistics.dislikeCount)) as int
			]
			
			return channel -> score
		]
	}
	
	def runIncrementalSearch() {	
		val channelIdToChannel = newHashMap()
		val allScores = newArrayList()
		
		println(0)
		var current = seed(15)
		
		for (i:1..4) {
			current.forEach[println("#" + it)]
			
			println(i)
			val scores = newArrayList
			current.evaluate.forEach[
				scores.add(it)
				allScores.add(it)
				channelIdToChannel.put(it.key.id, it.key)
			]
			scores.sort[one,two|Integer.compare(two.value, one.value)]
			current = scores.first(3).collectAll[
				key.brandingSettings.channel.featuredChannelsUrls
			].unique.filter[channelIdToChannel.get(it) == null].first(15).toList			
		}
		
		allScores.sort[one,two|Integer.compare(two.value, one.value)]
		allScores.first(10).forEach[
			println('''[«it.key.statistics.viewCount»:«it.key.statistics.subscriberCount»] «it.key.brandingSettings.channel.title»: «it.key.brandingSettings.hints.join(", ")['''«property»: "«value»"''']»''')
			println("-----------------------")
			println("")
		]
	}
	
	static def void main(String[] args) {		
		new YouTubeSearchExample("the binding of isaac", "en").runIncrementalSearch
	}
}