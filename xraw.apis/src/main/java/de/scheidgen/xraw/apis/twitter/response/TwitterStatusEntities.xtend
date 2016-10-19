package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.annotations.JSON
import de.scheidgen.xraw.annotations.Name
import java.util.List

@JSON
class TwitterStatusEntities {
	TwitterStatusEntities description
	List<TwitterHashtag> hashtags
	List<TwitterUrl> urls
	List<TwitterUserMention> user_mentions
}

@JSON
class TwitterUserEntities {
	TwitterUserUrlEntity description
	TwitterUserUrlEntity url
}

@JSON
class TwitterUserUrlEntity {
	List<TwitterUrl> urls
}

@JSON
class TwitterUrl {
	String display_url
    String expanded_url
    List<Integer> indices          
    String url
}

@JSON
class TwitterUserMention {
	@Name("id_str") String id
    List<Integer> indices
	String name
	String screen_name
}

@JSON
class TwitterHashtag {
	String text
	List<Integer> indices        
}
