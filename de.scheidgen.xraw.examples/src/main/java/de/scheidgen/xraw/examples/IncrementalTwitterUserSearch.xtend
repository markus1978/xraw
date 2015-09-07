package de.scheidgen.xraw.examples

import de.scheidgen.xraw.XRawScript
import de.scheidgen.xraw.apis.twitter.Twitter
import java.util.ArrayList
import de.scheidgen.xraw.apis.twitter.response.TwitterUser

class IncrementalTwitterUserSearch {
	static val keyword = "letsplay"
	static val (TwitterUser) => boolean filter = [
		it.description.contains(keyword) && it.followersCount > 100
	]
	
	def static void main(String[] args) {
		val twitter = XRawScript::createWithStore("data/store.xmi").serviceWithLogin(Twitter, "markus")
		
		val result = new ArrayList<TwitterUser>()
		
		var i = 0;
		while (result.size < 5) {
			val usersWithKeywords = twitter.users.search.q(keyword).page(i++).count(20).send
			result.addAll(usersWithKeywords.filter(filter))	
			println(result.size)
		}
		
		println("First increment " + result.size)
		result.forEach[println("[" + it.followersCount + "]" + it.name + ": " + it.description)]
		
		for (user: result) {
			println("# " + user.screenName)
			var String cursor = "-1"
			while (true) {
				println("%% " + cursor)
				val current = twitter.followers.list.userId(user.id).count(1000).cursor(cursor).send				
				result.addAll(current.users.filter(filter))	
				cursor = current.nextCursor
			}							
		}
		println("Second increment " + result.size)
		result.forEach[println("[" + it.followersCount + "]" + it.name + ": " + it.description)]		
	}
}