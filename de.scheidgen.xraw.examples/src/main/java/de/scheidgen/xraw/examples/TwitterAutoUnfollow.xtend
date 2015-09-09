package de.scheidgen.xraw.examples

import com.google.common.collect.AbstractIterator
import com.google.common.collect.FluentIterable
import de.scheidgen.xraw.XRawScript
import de.scheidgen.xraw.apis.twitter.Twitter
import de.scheidgen.xraw.apis.twitter.response.TwitterConnections

class TwitterAutoUnfollow {
	
	static def <E> Iterable<Iterable<E>> split(Iterable<? extends E> iterable, int splitSize) {
		return new FluentIterable<Iterable<E>> {			
			override iterator() {
				val source = iterable.iterator
				return new AbstractIterator<Iterable<E>> {	
					var boolean empty = true								
					override protected computeNext() {
						if (source.hasNext) {
							empty = false
							return new FluentIterable<E> {							
								override iterator() {
									return new AbstractIterator<E> {
										var i = 0									
										override protected computeNext() {
											if (source.hasNext && i++ < splitSize) {
												return source.next
											} else {
												return endOfData
											}
										}									
									}
								}							
							}						
						} else {
							if (empty) {
								new FluentIterable<E> {								
									override iterator() {
										return new AbstractIterator<E> {											
											override protected computeNext() {
												return endOfData
											}											
										}
									}									
								}
							} else {
								return endOfData							
							}
						}
					}					
				}
			}						
		}
	}
	
	static def <E> Iterable<E> first(Iterable<E> iterable, int size) {
		return iterable.split(size).findFirst[true]		
	}
	
	static def <E> E first(Iterable<E> iterable) {
		val iterator = iterable.iterator
		if (iterator.hasNext) {
			return iterator.next
	 	} else {
	 		return null
	 	} 
	}

	
	def static void main(String[] args) {		
		val screenName = "mscheidgen"
		val twitter = XRawScript::createWithStore("data/store.xmi").serviceWithLogin(Twitter, "markus")
		
		println('''Looking for false friends for "«screenName»"''')
		
		val friends = newArrayList
		var response = Twitter::safeCursor(twitter.friends.id.screenName(screenName).count(100)) [
			friends.addAll(it.ids)
		]
		println('''Found «friends.size» friends«IF response == null || response.rateLimitExeeded», before the rate limit was reached«ENDIF».''')
		
		val friendships = newArrayList
		response = Twitter::safeForEach(friends.split(100),[twitter.friendships.lookup.userId(it)], [
			friendships.addAll(it.xResult)
		])
		val notFollowingFriendIds = friendships.filter[!it.connections.contains(TwitterConnections.followed_by)].map[id]
		println('''Found «notFollowingFriendIds.size» false friends«IF response==null || response.rateLimitExeeded», before the rate limit was reached«ENDIF». Start unfollowing now.''')
		
		response = Twitter::safeForEach(notFollowingFriendIds.first(20), [twitter.friendships.destroy.userId(it)],[])
		println('''Sucessfully unfollowed xxx users«IF response != null», before the rate limit was reached«ENDIF».''')
	}
}