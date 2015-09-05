package de.scheidgen.social.twitter.response

import de.scheidgen.social.core.annotations.Name
import de.scheidgen.social.core.annotations.Response
import de.scheidgen.social.core.annotations.WithConverter
import de.scheidgen.social.twitter.converter.TwitterDateConverter
import java.util.Date

@Response
class TwitterStatus {
	Object coordinates	
	boolean favorited = false
	boolean truncated = false
    @WithConverter(TwitterDateConverter) Date created_at
    @Name("id_str") String id
    Object entities
    @Name("in_reply_to_user_id_str") String in_reply_to_user_id
    Object contributors
    String text
    int retweet_count
    @Name("in_reply_to_status_id_str") String in_reply_to_status_id
    Object geo
    boolean retweeted = false
    boolean possibly_sensitive = false
	Object place
    TwitterUser user
    String in_reply_to_screen_name
    String source
}

@Response
class TwitterEntities {}