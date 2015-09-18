package de.scheidgen.xraw.examples.searchgraph

import com.tinkerpop.blueprints.Direction
import com.tinkerpop.blueprints.Vertex
import com.tinkerpop.blueprints.impls.tg.TinkerGraph
import de.scheidgen.xraw.apis.youtube.YouTube
import de.scheidgen.xraw.apis.youtube.resources.YouTubeChannels
import de.scheidgen.xraw.apis.youtube.resources.YouTubeVideos
import de.scheidgen.xraw.script.XRawScript
import java.net.URL
import java.util.regex.Pattern
import org.jsoup.Jsoup

class YouTubeSearchGraphContributor implements SearchGraphContributor {
	val userCount = 3
	val contentCount = 3
	
	val youTube = XRawScript::get("data/store.json", "markus", YouTube)
	val platformId = "youtube"
	val SearchGraph searchGraph
	val TinkerGraph graph
	val Vertex platformNode

	new(SearchGraph searchGraph) {
		this.searchGraph = searchGraph
		this.graph = searchGraph.graph
		platformNode = graph.addVertex(platformId)
		platformNode.setProperty(NODE_TYPE, PLATFORM_TYPE)
		platformNode.setProperty(NODE_CONTENT, this)
	}

	/**
	 * Looks if there is already a channel with the given id. Retrieves channel contents if given contents is null. Adds a user edge.
	 */
	private def resolveOrAddContentNode(String contentId, YouTubeVideos givenContent, Vertex givenUserNode) {
		val nodeId = '''«platformId»:«CONTENT_TYPE»:«contentId»'''.toString
		val existingVertex = graph.getVertex(nodeId)
		val result = if (existingVertex == null) {
			val content = if (givenContent == null) {
				youTube.videos.list.part("snippet").id(contentId).xCheck.xResult.items.get(0)
			} else {
				givenContent
			}
			val contentNode = graph.addVertex(nodeId)
			contentNode.setProperty(NODE_TYPE, CONTENT_TYPE)
			contentNode.setProperty(NODE_CONTENT, content)			
			graph.addEdge(null, platformNode, contentNode, CONTENT_EDGE)
					
			contentNode
		} else {			
			existingVertex
		}
		
		if (result.getEdges(Direction.OUT, "owner").empty) {
			val userNode = if (givenUserNode == null) {
				resolveOrAddUserNode((result.getProperty(NODE_CONTENT) as YouTubeVideos).snippet.channelId, null)
			} else {
				givenUserNode
			}	
			
			graph.addEdge(null, result, userNode, OWNER_EDGE)
		}
		return result
	}
	
	private def resolveOrAddUserNode(String userId, YouTubeChannels givenContent) {
		val nodeId = '''«platformId»:«USER_TYPE»:«userId»'''.toString
		val existingVertex = graph.getVertex(nodeId)
		val result = if (existingVertex == null) {
			val content = if (givenContent == null) {
				youTube.channels.list.part("brandingSettings").id(userId).xCheck.xResult.items.get(0)
			} else {
				givenContent
			}
			val userNode = graph.addVertex(nodeId)
			userNode.setProperty(NODE_TYPE, USER_TYPE)
			userNode.setProperty(NODE_CONTENT, content)
			graph.addEdge(null, platformNode, userNode, USER_EDGE)
			userNode
		} else {
			existingVertex
		}
		
		return result
	}

	override addContentSearchResults(Vertex userNode, String searchStr) {
		// TODO confusing format/code
		val videoIds = youTube.search.list.part("snippet").q(searchStr).maxResults(contentCount).relevanceLanguage("en").channelId(
			(userNode.getProperty(NODE_CONTENT) as YouTubeChannels).id).type("video").xCheck.xResult.items.map [
			id.videoId
		]
		val videos = youTube.videos.list.part("snippet").id(videoIds.join(",")).xCheck.xResult.items
		return videos.map [resolveOrAddContentNode(it.id, it, userNode)].toList
	}

	override addUserSearchResults(String searchStr) {
		val channelIds = youTube.search.list.part("snippet").q(searchStr).relevanceLanguage("en").maxResults(userCount).type("channel").
			xCheck.xResult.items.map[id.channelId]
		val channels = youTube.channels.list.part("brandingSettings").id(channelIds.join(",")).xCheck.xResult.items

		return channels.map [resolveOrAddUserNode(it.id, it)].toList
	}

	private def retrieveChannelLinks(YouTubeChannels channel) {
		SearchGraph::findLinks(Jsoup::parse(new URL('''https://www.youtube.com/channel/«channel.id»/about'''), 1000))
	}

	override addLinks(Vertex node) {
		val nodeType = node.getProperty(NODE_TYPE)
		val linkStrings = if (nodeType == USER_TYPE) {
			(node.getProperty(NODE_CONTENT) as YouTubeChannels).retrieveChannelLinks
		} else if (nodeType == CONTENT_TYPE) {
			SearchGraph::findLinks((node.getProperty(NODE_CONTENT) as YouTubeVideos).snippet.description)
		}
		println(linkStrings.join("\n"))
		val result = newArrayList
		linkStrings.forEach [
			val linkTargetNode = searchGraph.resolveOrAddLinkTarget(it)
			if (linkTargetNode != null) {
				graph.addEdge(null, node, linkTargetNode, LINK_EDGE)
				result.add(linkTargetNode)				
			}
		]
		result
	}

	val youTubeChannelUrlRegex = Pattern.compile("(http(s)?://)?(www\\.)?youtube.com/channel/(?<id>[^/\\?]*).*$")
	val youTubeUserUrlRegex = Pattern.compile("(http(s)?://)?(www\\.)?youtube.com/user/(?<id>[^/\\?]*).*$")
	val youTubeVideoUrlRegex = Pattern.compile("(http(s)?://)?(www\\.)?youtube.com/watch?v=(?<id>[^&]*).*$")
	val youTubeShortVideoUrlRegex = Pattern.compile("(http(s)?://)?(www\\.)?youtu\\.be/(?<id>[^&]*).*$")

	private def match(String str, Pattern pattern, String groupName) {
		val matcher = pattern.matcher(str)
		return if(matcher.matches) matcher.group(groupName) else null
	}

	override Vertex resolveOrAddLinkTarget(String url) {
		val channelId = url.match(youTubeChannelUrlRegex, "id")
		val userName = url.match(youTubeUserUrlRegex, "id")
		val videoId = url.match(youTubeVideoUrlRegex, "id")
		val shortVideoId = url.match(youTubeShortVideoUrlRegex, "id")

		if (channelId != null) {
			return resolveOrAddUserNode(channelId, null)			
		} else if (userName != null) {
			val channel = youTube.channels.list.forUsername(userName).part("brandingSettings").xCheck.xResult.items.get(0)
			return resolveOrAddUserNode(channel.id, channel)			
		} else if (videoId != null) {
			return resolveOrAddContentNode(videoId, null, null)
		} else if (shortVideoId != null) {
			return resolveOrAddContentNode(shortVideoId, null, null)
		} else {
			return null
		}
	}

}