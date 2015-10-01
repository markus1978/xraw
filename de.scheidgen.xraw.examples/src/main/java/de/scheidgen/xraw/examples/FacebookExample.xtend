package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.facebook.Facebook
import de.scheidgen.xraw.script.XRawScript

class FacebookExample {
	static def void main(String[] args) {		
		val facebook = XRawScript::get("data/store", "markus", Facebook)
		
		val result = facebook.pages.id("cubemonstergames").fields("likes,about,name,description_html,website,posts{link,from}").xCheck.xResult
		
		println(result.about)		
		println(result.posts.data.map[it.link].join(", "))
		println("----")
		
		val searchResult = facebook.search.page.limit(1).q("markiplier").fields("likes,about,name,description_html,website,posts.limit(2){link,from}").xCheck.xResult
		for(aResult:searchResult.data) {
			println(aResult.about)		
			println(aResult.posts.data.map[it.link].join(", "))
			println("----")			
		}
	}
}