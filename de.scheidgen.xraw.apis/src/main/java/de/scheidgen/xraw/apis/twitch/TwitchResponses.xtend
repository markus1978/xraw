package de.scheidgen.xraw.apis.twitch

import de.scheidgen.xraw.json.Converter
import de.scheidgen.xraw.json.JSON
import de.scheidgen.xraw.json.Name
import de.scheidgen.xraw.json.WithConverter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.List

@JSON class TwitchSearchResult {
	@Name("_total") int total
	@Name("_links") TwitchListLinks links
}

@JSON class TwitchChannelList extends TwitchSearchResult {
	List<TwitchChannel> channels	
}

@JSON class TwitchVideoList extends TwitchSearchResult {
	List<TwitchVideo> videos	
}


@JSON class TwitchListLinks {
	@Name("self") String _self
	String next
}

@JSON class TwitchChannel {
	boolean mature = false
	String status
	String broadcaster_language
	String display_name
	String game
	int delay
	String language
	String _id
	String name
	@WithConverter(TwitchDateConverter) Date created_at
	@WithConverter(TwitchDateConverter) Date updated_at
	String logo
	String banner
	String video_banner
	String background
	String profile_banner
	String profile_banner_background_color
	boolean partner = false
	String url
	int views
	int followers
	TwitchLinks _links
}

class TwitchDateConverter implements Converter<Date> {
	override toValue(String str) {
		return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ").parse(str)
	}

	override toString(Date value) {
		return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ").format(value)
	}
}

@JSON class TwitchLinks {
	@Name("self") String _self
    String follows
	String commercial
	String stream_key
    String chat
    String features
    String subscriptions
    String editors
    String teams
    String videos
    String channel
}

@JSON class TwitchVideo {
	String title
    String description
    long broadcast_id
    String status
    String tag_list
    String _id
    @WithConverter(TwitchDateConverter) Date recorded_at
    String game
    int length
    String preview
    String url
    int views
    String broadcast_type
    @Name("_links") TwitchLinks links
	TwitchChannel channel      
}

class TwitchResponses {
}