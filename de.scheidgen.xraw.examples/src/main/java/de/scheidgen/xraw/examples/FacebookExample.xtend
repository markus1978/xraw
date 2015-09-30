package de.scheidgen.xraw.examples

import de.scheidgen.xraw.apis.facebook.Facebook
import de.scheidgen.xraw.script.XRawScript

class FacebookExample {
	static def void main(String[] args) {		
		val facebook = XRawScript::get("data/store", "markus", Facebook)
		
		val result = facebook.pages.id("cubemonstergames").fields("likes,about,name,description_html,website,posts{link,from}").xCheck.xResult
		
		println(result.about)		
	}
}