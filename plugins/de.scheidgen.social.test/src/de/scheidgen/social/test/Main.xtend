package de.scheidgen.social.test

import de.scheidgen.social.twitter.Twitter

class Main {
	
	static def main(String[] args) {
		val profile = SocialUtil::openProfile
		val twitter = Twitter.get(SocialUtil::getTwitterService(profile))
		
		twitter.statuses.userTimeline.send.forEach[
			println(text)
			println()
		]		
	}
}