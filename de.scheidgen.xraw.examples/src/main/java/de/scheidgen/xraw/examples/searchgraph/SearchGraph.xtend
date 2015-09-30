package de.scheidgen.xraw.examples.searchgraph

import com.tinkerpop.blueprints.Edge
import com.tinkerpop.blueprints.Vertex
import com.tinkerpop.blueprints.impls.tg.TinkerGraph
import com.tinkerpop.blueprints.oupls.jung.GraphJung
import edu.uci.ics.jung.algorithms.layout.FRLayout
import edu.uci.ics.jung.visualization.BasicVisualizationServer
import java.awt.Color
import java.awt.Dimension
import java.awt.Paint
import java.util.List
import javax.swing.JFrame
import org.apache.commons.collections15.Transformer
import org.eclipse.xtend.lib.annotations.Accessors
import org.jsoup.Jsoup
import org.jsoup.nodes.Document

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*
import static extension de.scheidgen.xraw.examples.searchgraph.SearchGraphContributor.*

interface SearchGraphContributor {
	static val NODE_TYPE = "type"
	static val NODE_CONTENT = "content"

	static val PLATFORM_TYPE = "platform"
	static val CONTENT_TYPE = "content"
	static val WEB_TYPE = "web"
	static val USER_TYPE = "user"
	
	static val USER_EDGE = "user"
	static val CONTENT_EDGE = "content"
	static val OWNER_EDGE = "owner"
	static val LINK_EDGE = "link"

	/**
	 * Performs a search for content of a specific user. Adds all the results
	 * to the graph and establishes edges between user nodes, platform node,
	 * and the created content nodes.
	 */
	def List<Vertex> addContentSearchResults(Vertex userNode, String searchStr)

	/**
	 * Performs a search for a user. Adds all the results to the graph
	 * and established edges between platform node and the create user node.
	 */
	def List<Vertex> addUserSearchResults(String searchStr)

	/**
	 * Looks for links in the given user or content node. Resolves those links
	 * and adds link targets to the graph.
	 */
	def List<Vertex> addLinks(Vertex node)

	/**
	 * Checks if the given url is for the contributor's platform. If true
	 * it resolves the identified content or user, or retrieves all necessary
	 * information and adds the identified resource to the graph.
	 */
	def Vertex resolveOrAddLinkTarget(String url)
}

class SearchGraph {
	@Accessors(PUBLIC_GETTER) val graph = new TinkerGraph
	val List<? extends SearchGraphContributor> contributors = #{
		new YouTubeSearchGraphContributor(this), 
		new TwitterSearchGraphContributor(this),
		new TwitchSearchGraphContributor(this)
	}.toList

	public static def findLinks(String code) {
		Jsoup::parse('''<html><body>«code»</body></html>''').findLinks
	}

	public static def findLinks(Document jsoupDoc) {
		return jsoupDoc.getElementsByClass("about-custom-links").collectAll [
			it.getElementsByTag("a").collect[it.attr("href")]
		]
	}


	public def resolveOrAddLinkTarget(String url) {
		// todo url normalization
		// todo shorteners
		val result = contributors.map[it.resolveOrAddLinkTarget(url)].findFirst[it != null]
		return if (result == null) {
			val existingWebNode = graph.getVertex(url)
			if (existingWebNode == null) {
				val webNode = graph.addVertex(url)
				webNode.setProperty(NODE_TYPE, WEB_TYPE)
				webNode.setProperty(NODE_CONTENT, url)
				webNode
			} else {
				existingWebNode
			}			
		} else {
			result
		}
	}

	public def build(String searchStr) {
		val firstOrderNodesWithContributors = newHashMap
		contributors.forEach [ contributor |
			val userNodes = contributor.addUserSearchResults(searchStr)
			userNodes.forEach[firstOrderNodesWithContributors.put(it, contributor)]
			userNodes.forEach [
				val contentNodes = contributor.addContentSearchResults(it, searchStr)
				contentNodes.forEach[node|firstOrderNodesWithContributors.put(it, contributor)]
			]
		]
		
		val secondOrderNodes = newArrayList
		firstOrderNodesWithContributors.keySet.forEach[node|
			val contributor = firstOrderNodesWithContributors.get(node)
			secondOrderNodes.addAll((contributor).addLinks(node))
		]
	}

	static public def void main(String[] args) {
		val searchGraph = new SearchGraph()
		searchGraph.build("markiplier")
		println(searchGraph.graph.vertices.join(",")[it.id.toString])
		
		val graph = new GraphJung(searchGraph.graph)
		
		val layout = new FRLayout<Vertex, Edge>(graph)
		layout.size = new Dimension(1600, 1100)
		val viz = new BasicVisualizationServer<Vertex, Edge>(layout);
		viz.preferredSize = new Dimension(1600, 1100)

		val vertexLabelTransformer = new Transformer<Vertex, String>() {
		    override String transform(Vertex vertex) {
		      return vertex.id as String
		    }
		}
		
		val vertexFillTransformer = new Transformer<Vertex, Paint>() {
		    override Paint transform(Vertex vertex) {
		   		var id = vertex.id.toString
		      	while (id.lastIndexOf(":") != -1) {
		      		id = id.substring(0, id.lastIndexOf(":"))
		      	}
		      	if (id.toLowerCase=="youtube") {
		      		Color.RED		      		
		      	} else if (id.toLowerCase=="twitter") {
		      		Color.BLUE
		      	} else if (id.toLowerCase=="twitch") {
		      		Color.MAGENTA
		      	} else {
		      		Color.BLACK
		      	}
		    }
		}
		
		val edgeLabelTransformer = new Transformer<Edge, String>() {
		    override String transform(Edge edge) {
		      return edge.label
		    }
		}

		viz.getRenderContext().setEdgeLabelTransformer(edgeLabelTransformer);
		viz.getRenderContext().setVertexLabelTransformer(vertexLabelTransformer);
		viz.getRenderContext().vertexFillPaintTransformer = vertexFillTransformer
		

		val frame = new JFrame("SearchGraph")
		frame.setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
		frame.getContentPane().add(viz)
		frame.pack()
		frame.setVisible(true)
		
		searchGraph.graph.shutdown
	}
}

