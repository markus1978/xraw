package de.scheidgen.xraw.examples

import com.github.scribejava.apis.TwitterApi
import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.response.TwitterUser
import de.scheidgen.xraw.http.ScribeOAuth1Service
import de.scheidgen.xraw.script.XRawScript
import java.util.ArrayList

class IncrementalTwitterUserSearch {
	static val keyword = "letsplay"
	static val (TwitterUser) => boolean filter = [
		it.description.contains(keyword) && it.followersCount > 100
	]
	
	def static void main(String[] args) {
		val twitter = XRawScript::get("data/store.xmi", "markus", Twitter) [new ScribeOAuth1Service(TwitterApi.instance, it)]
		
		val result = new ArrayList<TwitterUser>()
		
		var i = 0;
		while (result.size < 5) {
			val usersWithKeywords = twitter.users.search.q(keyword).page(i++).count(20).xExecute.xResult
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
				val current = twitter.followers.list.userId(user.id).count(1000).cursor(cursor).xExecute.xResult				
				result.addAll(current.users.filter(filter))	
				cursor = current.nextCursor
			}							
		}
		println("Second increment " + result.size)
		result.forEach[println("[" + it.followersCount + "]" + it.name + ": " + it.description)]		
	}
}