package de.scheidgen.xraw.examples.powersearch

import de.scheidgen.xraw.apis.youtube.YouTube
import de.scheidgen.xraw.apis.youtube.resources.YouTubeChannels
import de.scheidgen.xraw.apis.youtube.resources.YouTubeVideos
import de.scheidgen.xraw.script.XRawScript
import de.scheidgen.xraw.util.AddConstructor
import de.scheidgen.xraw.util.AddSuperConstructors
import java.net.URL
import java.util.List
import java.util.Map
import java.util.regex.Pattern
import org.eclipse.xtend.lib.annotations.Accessors
import org.jsoup.Jsoup
import org.jsoup.nodes.Document

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*

@AddConstructor
class SGNode<E> {
	@Accessors(PUBLIC_GETTER) val E source
}

class SGMetaUser {
	
}

@AddSuperConstructors
class SGUser<E> extends SGNode<E> {
	@Accessors(PUBLIC_GETTER) val List<SGContent<?>> contents = newArrayList
}

class SGPlatform {
	
}

class SGWebSite {
	
}

@AddConstructor
class SGLink<T extends SGNode<?>> {
	@Accessors(PUBLIC_GETTER) val T target
}

@AddSuperConstructors
class SGContent<E> extends SGNode<E> {
	@Accessors(PUBLIC_GETTER, PACKAGE_SETTER) var SGUser<?> user = null
}

interface SearchGraphContributor {
	def SGPlatform getPlatform()
	def List<SGContent<?>> contentSearch(SGUser<?> user, String searchStr)
	def List<SGUser<?>> userSearch(String searchStr)
	def SGContent<?> profile(SGUser<?> user)
	def List<SGLink<?>> links(SGContent<?> content)
	def SGLink<?> resolve(String linkStr)
}

class SearchGraph {
	val Map<SGPlatform, SearchGraphContributor> contributors
	new() {
		val youtube = new SGPlatform
		contributors = #{youtube -> new YouTubeSearchGraphContributor(this, youtube)}
	}
	
	public static def findLinks(String code) {
		Jsoup::parse('''<html><body>«code»</body></html>''').findLinks
	}
	
	public static def findLinks(Document jsoupDoc) {
		return jsoupDoc.getElementsByClass("about-custom-links").collectAll[
			it.getElementsByTag("a").collect[it.attr("href")]
		]
	}
	
	public def resolveLink(String link) {
		// todo shorteners
		return contributors.values.map[it.resolve(link)].findFirst[it!=null]
	}
	
	public def build(String searchStr) {
		val List<SGNode<?>> nodes = newArrayList
		contributors.values.forEach[contributor| 
			val users = contributor.userSearch(searchStr)
			nodes.addAll(users)
			nodes.addAll(users.map[contributor.profile(it)])
			users.forEach[
				nodes.addAll(contributor.contentSearch(it, searchStr))
			]			
		]
		
		return nodes
	}
	
	static public def void main(String[] args) {
		val nodes = new SearchGraph().build("markiplier")
		println(nodes.length)
	}
}

@AddConstructor
class YouTubeSearchGraphContributor implements SearchGraphContributor {	
	val youTube = XRawScript::get("data/store.json", "markus", YouTube)
	val SearchGraph searchGraph
	@Accessors(PUBLIC_GETTER) val SGPlatform platform	
	
	override contentSearch(SGUser<?> user, String searchStr) {
		val videoIds = youTube.search.list
			.part("snippet")
			.q(searchStr)
			.relevanceLanguage("en")
			.channelId((user.source as YouTubeChannels).id)
			.type("video")
			.xCheck
			.xResult.items.map[id.videoId]
		val videos = youTube.videos.list
			.part("snippet")
			.id(videoIds.join(","))
			.xCheck.xResult.items
		return videos.map[
			val result = new SGContent<YouTubeVideos>(it)
			result.user = user
			user.contents.add(result)
			return result
		]
	}
	
	override userSearch(String searchStr) {
		val channelIds = youTube.search.list
			.part("snippet")
			.q(searchStr)
			.relevanceLanguage("en")
			.type("channel")
			.xCheck
			.xResult.items.map[id.channelId]
		val channels = youTube.channels.list
			.part("brandingSettings")
			.id(channelIds.join(","))
			.xCheck.xResult.items
		return channels.map[new SGUser<YouTubeChannels>(it)]
	}
	
	override profile(SGUser<?> user) {
		val result = new SGContent<YouTubeChannels>(user.source as YouTubeChannels)
		result.user = user
		user.contents += result
		return result
	}
	
	private def retrieveChannelLinks(YouTubeChannels channel) {
		SearchGraph::findLinks(Jsoup::parse(new URL('''https://www.youtube.com/channel/«channel.id»/about'''), 1000))
		
	}
	
	override links(SGContent<?> content) {
		val source = content.source
		val linkStrings = switch(source) {
			case source instanceof YouTubeChannels: (source as YouTubeChannels).retrieveChannelLinks
			case source instanceof YouTubeVideos: SearchGraph::findLinks((source as YouTubeVideos).snippet.description)
			default: throw new IllegalStateException
		}
		linkStrings.map[searchGraph.resolveLink(it)].toList
	}
	
	val youTubeChannelUrlRegex = Pattern.compile("(http(s)?://)?(www\\.)?youtube/channel/(?<id>[^/]*).*$")
	val youTubeUserUrlRegex = Pattern.compile("(http(s)?://)?(www\\.)?youtube/user/(?<id>[^/]*).*$")
	val youTubeVideoUrlRegex = Pattern.compile("(http(s)?://)?(www\\.)?youtube/watch?v=(?<id>[^&]*).*$")
	val youTubeShortVideoUrlRegex = Pattern.compile("(http(s)?://)?(www\\.)?youtu\\.be/(?<id>[^&]*).*$")
	
	def match(String str, Pattern pattern, String groupName) {
		val matcher = pattern.matcher(str)
		return if (matcher.matches)	matcher.group(groupName) else null
	}
	
	override resolve(String linkStr) {
		val channelId = linkStr.match(youTubeChannelUrlRegex, "id")
		val userName = linkStr.match(youTubeUserUrlRegex, "id")
		val videoId = linkStr.match(youTubeVideoUrlRegex, "id")
		val shortVideoId = linkStr.match(youTubeShortVideoUrlRegex, "id")
		
		if (channelId != null) {
			return new SGLink<SGContent<?>>(new SGContent<YouTubeChannels>(
				youTube.channels.list
					.id(channelId)
					.part("brandingSettings")
					.xCheck.xResult.items.get(0)
			))
		} else if (userName != null) {
			return new SGLink<SGContent<?>>(new SGContent<YouTubeChannels>(
				youTube.channels.list
					.forUsername(userName)
					.part("brandingSettings")
					.xCheck.xResult.items.get(0)
			))
		} else if (videoId != null) {
			return new SGLink<SGContent<?>>(new SGContent<YouTubeVideos>(
				youTube.videos.list
					.id(videoId)
					.part("snippet")
					.xCheck.xResult.items.get(0)
			))
		} else if (shortVideoId != null) {
			return new SGLink<SGContent<?>>(new SGContent<YouTubeVideos>(
				youTube.videos.list
					.id(shortVideoId)
					.part("snippet")
					.xCheck.xResult.items.get(0)
			))
		} else {
			return null
		}
	}
	
	
}