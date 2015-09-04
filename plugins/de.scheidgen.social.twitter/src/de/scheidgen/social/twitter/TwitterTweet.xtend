package de.scheidgen.social.twitter

import de.scheidgen.social.core.annotations.Converter
import de.scheidgen.social.core.annotations.Name
import de.scheidgen.social.core.annotations.Response
import de.scheidgen.social.core.annotations.WithConverter
import java.text.SimpleDateFormat
import java.util.Date

@Response
class TwitterTweet {
	Object coordinates	
	boolean favorited	
	boolean truncated
    @Name("created_at") @WithConverter(TwitterDateConverter) Date createdAt
    @Name("id_str") String id
    Object entities
    @Name("in_reply_to_user_id_str") String inReplyToUserIdStr
    Object contributors
    String text
    @Name("retweet_count") int retweetCount
    @Name("in_reply_to_status_id_str") String inReplyToStatusId
    Object geo
    boolean retweeted
    @Name("possibly_sensitive") boolean possiblySensitive
    @Name("in_reply_to_user_id") Long inReplyToUserId
	Object place
    Object user
    @Name ("in_reply_to_screen_name") String inReplyToScreenName
    String source
}

class TwitterDateConverter implements Converter<Date> {	
	override Date convert(String value) {
		return new SimpleDateFormat("EEE MMM dd HH:mm:ss ZZZZZ yyyy").parse(value);
	}	
}

@Response
class TwitterEntities {}