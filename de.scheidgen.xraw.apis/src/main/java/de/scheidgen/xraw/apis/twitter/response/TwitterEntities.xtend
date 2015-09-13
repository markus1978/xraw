package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.annotations.Name
import de.scheidgen.xraw.annotations.UrlConverter
import de.scheidgen.xraw.annotations.WithConverter
import java.net.URL
import java.util.List
import de.scheidgen.xraw.annotations.JSON

@JSON
class TwitterEntities {
	List<TwitterHashtag> hashtags
	List<TwitterUrl> urls
	List<TwitterUserMention> user_mentions
}

@JSON
class TwitterUrl {
	String display_url
    String expanded_url
    int[] indices          
    @WithConverter(UrlConverter) URL url
}

@JSON
class TwitterUserMention {
	@Name("id_str") String id
    int[] indices
	String name
	String screen_name
}

@JSON
class TwitterHashtag {
	String text
	int[] indices        
}
