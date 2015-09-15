package de.scheidgen.xraw.examples.powersearch

import de.scheidgen.xraw.apis.youtube.YouTube
import de.scheidgen.xraw.apis.youtube.resources.YouTubeChannels
import de.scheidgen.xraw.script.XRawScript
import de.scheidgen.xraw.util.AddConstructor
import de.scheidgen.xraw.util.AddSuperConstructors
import de.scheidgen.xraw.util.XRawIterateExtensions
import java.util.Collection
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*
import org.junit.Test

@AddConstructor
abstract class SingleAPIPowerSearch<Id, Info> {

	/**
	 * @return The search seed, i.e. a {@link Iterable} of random resource {@link Id}s that have the potential to fit the search.
	 */
	abstract def Iterable<Id> seed(int count)

	/**
	 * @return A pair consisting of detailed information and a search relevance score of resource with the given id.
	 */
	abstract def Map<Id, Pair<Info, Integer>> evaluate(Iterable<Id> ids)	

	/**
	 * @return An {@ Iterable} of related resources that could also fit the search.
	 */	
	abstract def Iterable<Id> related(Id id, Info info)

	@Accessors(PROTECTED_GETTER) val String keywordStr
	val int depth
	val int width
	
	extension val XRawIterateExtensions iterateExtensions = XRawIterateExtensions::standard
	@Accessors(PROTECTED_GETTER) val cie = XRawIterateExtensions::concurrent
	
	final def run() {
		val nextCount = width
		val nextSeedCount = nextCount / 4
		
		val Map<Id, Pair<Info,Integer>> allIdToInfoScores = newHashMap // all evaluted ids
		val List<Id> allIds = newArrayList
		val Collection<Id> allNextSeedIds = newHashSet
		var Iterable<Id> nextIterationIds // the ids for the next iteration
		
		var first = true
		for (i:0..depth) {
			if (first) {
				first = false
				nextIterationIds = seed(nextCount).first(nextCount).toList
			} else {
				val nextSeedIds = allIds.filter[!allNextSeedIds.contains(it)].first(nextSeedCount).toList	
				allNextSeedIds.addAll(nextSeedIds)	
				val tmp = nextSeedIds.map[
					val result = related(allIdToInfoScores.get(it).key)
					if (result == null) {
						result
					} else {
						result
					}
				].flatten.toList	
				nextIterationIds = tmp.unique.filter[!allIdToInfoScores.containsKey(it)].first(nextCount).toList
			}
 			
 			allIds.addAll(nextIterationIds)
			allIdToInfoScores.putAll(nextIterationIds.evaluate)		
			
			allIds.sort[a,b|Integer.compare(allIdToInfoScores.get(b).value, allIdToInfoScores.get(a).value)]
		} 
		
		return allIds.first(10).map[allIdToInfoScores.get(it)].toList
	}
}

class TestPowerSearch extends SingleAPIPowerSearch<Integer, Integer> {
	
	new(String keywordStr, int depth, int width) {
		super(keywordStr, depth, width)
	}
	
	override seed(int count) {
		return 0..100
	}
	
	override evaluate(Iterable<Integer> ids) {
		val result = newHashMap
		ids.forEach[result.put(it, it -> (1000-it))]
		return result;
	}
	
	override related(Integer id, Integer info) {
		return 0..5
	}
	
}

class PowerSearchTests {
	@Test def void test() {
		println(new TestPowerSearch("", 5, 10).run.first(10).join(","))
	}
}

@AddSuperConstructors
class YouTubePowerSearch extends SingleAPIPowerSearch<String, YouTubeChannels> {
	
	val youtube = XRawScript::get("data/store.json", "markus", YouTube)
	
	override seed(int count) {
		return youtube.search.list
			.part("snippet")
			.q(keywordStr)
			.relevanceLanguage("en")
			.type("video")
			.order("viewCount")
			.videoDuration("medium")
			.maxResults(count)
			.xCheck.xResult.items.map[snippet.channelId].unique
	}
	
	override evaluate(Iterable<String> ids) {
		val channelsList = youtube.channels.list
			.part("statistics,brandingSettings")
			.id(ids.join(","))
			.maxResults(50)
			.xCheck.xResult.items
		
		val Map<String, Pair<YouTubeChannels,Integer>> result = newHashMap
		cie.foreach(channelsList)[channel|
			val totalNumberOfVideos = youtube.search.list
				.part("snippet")
				.q(keywordStr)
				.type("video")
				.videoDuration("medium")
				.channelId(channel.id)
				.order("rating")
				.maxResults(0)
				.xCheck.xResult.pageInfo.totalResults
			
			if (ids.filter[it == channel.id] == null) {
				throw new IllegalStateException("AHHH")
			}	
				
			result.put(channel.id, channel->totalNumberOfVideos)
			return null
		]
		return result
	}
		
	override related(String id, YouTubeChannels info) {
		val result = info.brandingSettings.channel.featuredChannelsUrls
		if (result == null) #{} else result
	}
	
	static def main(String[] args) {
		val results = new YouTubePowerSearch("the binding of isaac", 10, 25).run
		results.forEach[
			println('''«it.value»: [«it.key.statistics.subscriberCount»] "«it.key.brandingSettings.channel.title»"''')
		]
	}
}