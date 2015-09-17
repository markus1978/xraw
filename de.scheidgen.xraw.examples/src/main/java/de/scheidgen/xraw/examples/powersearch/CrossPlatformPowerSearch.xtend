package de.scheidgen.xraw.examples.powersearch

import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.Multimap
import java.util.List

import static de.scheidgen.xraw.examples.powersearch.CrossPlatformPowerSearchTests.*

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*
import de.scheidgen.xraw.util.AddConstructor
import org.junit.Test

interface Platform {	
	def List<? extends Content> userSearch(String searchStr)
	def boolean hasSearch()
	def Content getContent(String link)
}

interface Content {
	def List<String> getLinks()
	def User getOwner()
}

interface User {
	def List<? extends Content> getContent(int order)
}

@AddConstructor
class CrossPlatformPowerSearch {
	val List<? extends Platform> platforms
	
	def run(String searchStr) {
		// C::user[1]:U; C::links[*]:C; U::/metaUser[*]:U
		// metaUser = c[c.user=it].links*.user
		
		// create content user pairs based on searches performed on all platforms
		val contentToUser = platforms.filter[hasSearch].map[userSearch(searchStr).map[it->it.owner].filter[value!=null]].flatten.toList
		// add content user pairs based on 0nd and 1st order content of users collected so far on all platforms
		contentToUser.addAll(contentToUser.map[value.getContent(0).union(value.getContent(1)).map[it->it.owner]].flatten.toList)
		
		// gather linked contents from all contents collected so far
		val Multimap<Content, Content> contentToLinkedContents = ArrayListMultimap::create
		contentToUser.unique[it.key].forEach[
			val content = it.key
			content.links.forEach[link|
				contentToLinkedContents.put(content, content)
				contentToLinkedContents.put(content, platforms.map[getContent(link)].findFirst[it!=null])
			]
		]
		
		// derive meta-users based on collection content->user pairs and all links content->[content]
		val users = contentToUser.map[value].unique
		return users.map[user|
			contentToUser.filter[value==user].map[contentToLinkedContents.get(it.key)].flatten.map[owner].unique.toSet
		].unique
	}
}


class CrossPlatformPowerSearchTests {
	static val contentsDef = #{"tu1c0", "tu1c1", "yu1c0"}
	static val linksDef = #{"tu1c0"->"yu1c0"}
	
	static val contents = contentsDef.map[it->new TestContent(it)].toList
	static val users = contentsDef.map[substring(0,3)].unique.map[it->new TestUser(it)].toList
	static val platforms = contentsDef.map[substring(0,1)].unique.map[new TestPlatform(it)].toList
	
	static class TestContent implements Content {
		val String name new(String name) {this.name=name} override toString() { name }
		override getLinks() {
			linksDef.entrySet.filter[it.key==name].map[link|contents.findFirst[contents|contents.key==link.value].key].toList
		}
		
		override getOwner() {
			users.findFirst[key==name.substring(0,3)]?.value
		}		
	}
	
	static class TestUser implements User {
		val String name new(String name) {this.name=name} override toString() { name }		
		override getContent(int order) {
			contentsDef.filter[it.endsWith(""+order)]
				.filter[it.substring(0,3)==name]
				.map[contentName|contents.findFirst[it.key==contentName]?.value]
				.toList
		}		
	}	
	
	static class TestPlatform implements Platform {
		val String name new(String name) {this.name=name} override toString() { name }
		override userSearch(String searchStr) { contents.filter[key.startsWith(name)].filter[key.substring(1).startsWith(searchStr)].map[value].toList }		
		override hasSearch() { true }		
		override getContent(String link) { contents.findFirst[key==link]?.value }		
	}	
	
	static def void main(String[] args) {
		val search = new CrossPlatformPowerSearch(CrossPlatformPowerSearchTests::platforms)
		println(search.run("u1").join("\n"))
	}
}