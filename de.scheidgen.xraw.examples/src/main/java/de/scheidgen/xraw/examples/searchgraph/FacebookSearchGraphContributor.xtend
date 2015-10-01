package de.scheidgen.xraw.examples.searchgraph

import com.tinkerpop.blueprints.Direction
import com.tinkerpop.blueprints.Vertex
import com.tinkerpop.blueprints.impls.tg.TinkerGraph
import de.scheidgen.xraw.script.XRawScript
import java.util.regex.Pattern
import de.scheidgen.xraw.apis.facebook.Facebook
import de.scheidgen.xraw.apis.facebook.FacebookPost
import de.scheidgen.xraw.apis.facebook.FacebookPage

class FacebookSearchGraphContributor implements SearchGraphContributor {
	val userCount = 3
	val contentCount = 3
	
	val pageReadFields = '''likes,about,id,name,description_html,website,posts.limit(«contentCount»){link,from,id}'''.toString
	
	val facebook = XRawScript::get("data/store.json", "markus", Facebook)
	val platformId = "facebook"
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

	private def resolveOrAddContentNode(String contentId, FacebookPost givenContent, Vertex givenUserNode) {
		val nodeId = '''«platformId»:«CONTENT_TYPE»:«contentId»'''.toString
		val existingVertex = graph.getVertex(nodeId)
		val result = if (existingVertex == null) {
			val content = if (givenContent == null) {
				facebook.posts.id(contentId).fields("link").xCheck.xResult				
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
				resolveOrAddUserNode((result.getProperty(NODE_CONTENT) as FacebookPost).from.id, null)
			} else {
				givenUserNode
			}	
			
			graph.addEdge(null, result, userNode, OWNER_EDGE)
		}
		return result
	}
	
	private def resolveOrAddUserNode(String userId, FacebookPage givenContent) {
		val nodeId = '''«platformId»:«USER_TYPE»:«userId»'''.toString
		val existingVertex = graph.getVertex(nodeId)
		val result = if (existingVertex == null) {
			val content = if (givenContent == null) {
				facebook.pages.id(userId).fields(pageReadFields).xCheck.xResult
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
		// TODO perform an actual search within the posts, not just take all recent posts?
		val page = userNode.getProperty(NODE_CONTENT) as FacebookPage	
		return page.posts.data.map [resolveOrAddContentNode(it.id, it, userNode)].toList
	}

	override addUserSearchResults(String searchStr) {
		val facebookPages = facebook.search.page.q(searchStr).limit(userCount).fields(pageReadFields).xCheck.xResult.data
		return facebookPages.map [resolveOrAddUserNode(it.id, it)].toList
	}

	override addLinks(Vertex node) {
		val nodeType = node.getProperty(NODE_TYPE)
		val linkStrings = if (nodeType == USER_TYPE) {
				val page = (node.getProperty(NODE_CONTENT) as FacebookPage)
				#{page.website}
			} else if (nodeType == CONTENT_TYPE) {
				val post = (node.getProperty(NODE_CONTENT) as FacebookPost)
				#{post.link}
			}
		println(linkStrings.join("\n"))
		val result = newArrayList
		linkStrings.filter[it!=null].forEach [
			val linkTargetNode = searchGraph.resolveOrAddLinkTarget(it)
			if (linkTargetNode != null) {
				graph.addEdge(null, node, linkTargetNode, LINK_EDGE)
				result.add(linkTargetNode)				
			}
		]
		result
	}

	val facebookChannelUrlRegex = Pattern.compile("^https?://(www\\.)?facebook\\.com/(?<id>[^/\\?]+)$")
	

	private def match(String str, Pattern pattern, String groupName) {
		val matcher = pattern.matcher(str)
		return if(matcher.matches) matcher.group(groupName) else null
	}

	override Vertex resolveOrAddLinkTarget(String url) {
		val pageName = url.match(facebookChannelUrlRegex, "id")		

		if (pageName != null) {
			val pages = facebook.search.page.q(pageName).fields(pageReadFields).xCheck.xResult.data
			val first = pages?.findFirst[it.name.toLowerCase==pageName.toLowerCase]
			return if (first != null) resolveOrAddUserNode(first.id, first) else null			
		} else {
			return null
		}
	}
}