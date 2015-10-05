package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.json.JSON
import de.scheidgen.xraw.json.Name
import de.scheidgen.xraw.json.UrlConverter
import de.scheidgen.xraw.json.WithConverter
import java.net.URL
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
    @WithConverter(UrlConverter) URL url
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
