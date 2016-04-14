package de.scheidgen.xraw.examples.searchgraph

import com.tinkerpop.blueprints.Direction
import com.tinkerpop.blueprints.Vertex
import com.tinkerpop.blueprints.impls.tg.TinkerGraph
import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.response.TwitterStatus
import de.scheidgen.xraw.apis.twitter.response.TwitterUser
import de.scheidgen.xraw.oauth.ScribeOAuth1Service
import de.scheidgen.xraw.script.XRawScript
import java.util.regex.Pattern
import org.scribe.builder.api.TwitterApi

class TwitterSearchGraphContributor implements SearchGraphContributor {
	val userCount = 3
	val contentCount = 3
	
	val twitter = XRawScript::get("data/store.json", "markus", Twitter) [new ScribeOAuth1Service(TwitterApi, it)]
	val platformId = "twitter"
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

	private def resolveOrAddContentNode(String contentId, TwitterStatus givenContent, Vertex givenUserNode) {
		val nodeId = '''«platformId»:«CONTENT_TYPE»:«contentId»'''.toString
		val existingVertex = graph.getVertex(nodeId)
		val result = if (existingVertex == null) {
			val content = if (givenContent == null) {
				twitter.statuses.show.id(contentId).includeEntities(true).xCheck.xResult
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
				resolveOrAddUserNode((result.getProperty(NODE_CONTENT) as TwitterStatus).user.id, null)
			} else {
				givenUserNode
			}	
			
			graph.addEdge(null, result, userNode, OWNER_EDGE)
		}
		return result
	}
	
	private def resolveOrAddUserNode(String userId, TwitterUser givenContent) {
		val nodeId = '''«platformId»:«USER_TYPE»:«userId»'''.toString
		val existingVertex = graph.getVertex(nodeId)
		val result = if (existingVertex == null) {
			val content = if (givenContent == null) {
				twitter.users.show.userId(userId).includeEntities(true).xCheck.xResult
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
		val userId = (userNode.getProperty(NODE_CONTENT) as TwitterUser).id
		val statuses = twitter.statuses.userTimeline.userId(userId).count(contentCount).xCheck.xResult		
		return statuses.map [resolveOrAddContentNode(it.id, it, userNode)].toList
	}

	override addUserSearchResults(String searchStr) {
		val users = twitter.users.search.q(searchStr).count(userCount).includeEntities(true).xCheck.xResult		
		return users.map [resolveOrAddUserNode(it.id, it)].toList
	}

	override addLinks(Vertex node) {
		val nodeType = node.getProperty(NODE_TYPE)
		val linkStrings = if (nodeType == USER_TYPE) {
				val twitterUser = (node.getProperty(NODE_CONTENT) as TwitterUser)
				val description = twitterUser.entities?.description
				val url = twitterUser.entities.url
				val links = newArrayList
				if (description != null) links.addAll(description.urls)
				if (url != null)  links.addAll(url.urls)
				links.map[it.expandedUrl]
			} else if (nodeType == CONTENT_TYPE) {
				(node.getProperty(NODE_CONTENT) as TwitterStatus).entities.urls.map[it.expandedUrl]
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

	val twitterUserUrlRegex = Pattern.compile("^https?://(www\\.)?twitter\\.com/(#!/)?@?(?<id>[^/\\?]+)$")
	

	private def match(String str, Pattern pattern, String groupName) {
		val matcher = pattern.matcher(str)
		return if(matcher.matches) matcher.group(groupName) else null
	}

	override Vertex resolveOrAddLinkTarget(String url) {
		val userName = url.match(twitterUserUrlRegex, "id")		

		if (userName != null) {
			val twitterUser = twitter.users.show.screenName(userName).includeEntities(true).xCheck.xResult
			return resolveOrAddUserNode(twitterUser.id, twitterUser)			
		} else {
			return null
		}
	}
}