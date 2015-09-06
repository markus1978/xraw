package de.scheidgen.xraw.apis.tumblr.response

import de.scheidgen.xraw.apis.tumblr.converter.TumblrDateConverter
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.WithConverter
import java.util.Date

@Response
class TumblrBlog {
	
	/**
	 * The display title of the blog. Compare name.
	 */
	String title
	
	/**
	 * The total number of posts to this blog
	 */
	int posts
	 
	 
	/**
	 * The short blog name that appears before tumblr.com in a standard blog hostname (and before the domain in a custom blog hostname). Compare title.
	 */
	String name

	/**
	 * The time of the most recent post, in seconds since the epoch.
	 */
	@WithConverter(TumblrDateConverter) Date updated
	
	/**
	 * You guessed it! The blog's description.
	 */
	String description 		 

	/**
	 * Indicates whether the blog allows questions.
	 */
	boolean ask = false		 

	/**
	 * Indicates whether the blog allows anonymous questions. Returned only if ask is true.
	 */
	boolean ask_anon = false
	
	/**
	 * Number of likes for this user	Returned only if this is the user's primary blog and sharing of likes is enabled.
	 */
	int likes
	
	/**
	 * Indicates whether this blog has been blocked by the calling user's primary blog	Returned only if there is an authenticated user making this call 
	 */
	boolean is_blocked_from_primary	= false
}