package de.scheidgen.xraw.examples.searchgraph

import com.tinkerpop.blueprints.Direction
import com.tinkerpop.blueprints.Vertex
import com.tinkerpop.blueprints.impls.tg.TinkerGraph
import de.scheidgen.xraw.apis.twitch.Twitch
import de.scheidgen.xraw.apis.twitch.TwitchChannel
import de.scheidgen.xraw.apis.twitch.TwitchVideo
import de.scheidgen.xraw.script.XRawScript
import java.util.regex.Pattern

class TwitchSearchGraphContributor implements SearchGraphContributor {
	val userCount = 3
	val contentCount = 3
	
	val twitch = XRawScript::get("data/store.json", "markus", Twitch)
	val platformId = "twitch"
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

	private def resolveOrAddContentNode(String contentId, TwitchVideo givenContent, Vertex givenUserNode) {
		val nodeId = '''«platformId»:«CONTENT_TYPE»:«contentId»'''.toString
		val existingVertex = graph.getVertex(nodeId)
		val result = if (existingVertex == null) {
			val content = if (givenContent == null) {
				twitch.video.id(contentId).xCheck.xResult
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
				resolveOrAddUserNode((result.getProperty(NODE_CONTENT) as TwitchVideo).channel.name, null)
			} else {
				givenUserNode
			}	
			
			graph.addEdge(null, result, userNode, OWNER_EDGE)
		}
		return result
	}
	
	private def resolveOrAddUserNode(String userId, TwitchChannel givenContent) {
		val nodeId = '''«platformId»:«USER_TYPE»:«userId»'''.toString
		val existingVertex = graph.getVertex(nodeId)
		val result = if (existingVertex == null) {
			val content = if (givenContent == null) {
				twitch.channel.channelName(userId).xCheck.xResult
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
		val userId = (userNode.getProperty(NODE_CONTENT) as TwitchChannel).name
		val videos = twitch.channelVideos.channelName(userId).limit(contentCount).xCheck.xResult.videos	
		return videos.map [resolveOrAddContentNode(it.id, it, userNode)].toList
	}

	override addUserSearchResults(String searchStr) {
		val users = twitch.channelSearch.q(searchStr).limit(userCount).xCheck.xResult.channels		
		return users.map [resolveOrAddUserNode(it.name, it)].toList
	}

	override addLinks(Vertex node) {
		val nodeType = node.getProperty(NODE_TYPE)
		val linkStrings = if (nodeType == USER_TYPE) {
				val channel = (node.getProperty(NODE_CONTENT) as TwitchChannel)
				twitch.channelPanels.channelName(channel.name).xCheck.xResult.map[data.link]
			} else if (nodeType == CONTENT_TYPE) {
				val video = (node.getProperty(NODE_CONTENT) as TwitchVideo)
				SearchGraph::findLinks(video.description)
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

	val twitchChannelUrlRegex = Pattern.compile("^https?://(www\\.)?twitch\\.tv/(?<id>[^/\\?]+)$")
	

	private def match(String str, Pattern pattern, String groupName) {
		val matcher = pattern.matcher(str)
		return if(matcher.matches) matcher.group(groupName) else null
	}

	override Vertex resolveOrAddLinkTarget(String url) {
		val channelName = url.match(twitchChannelUrlRegex, "id")		

		if (channelName != null) {
			return resolveOrAddUserNode(channelName, null)			
		} else {
			return null
		}
	}
}