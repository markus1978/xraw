package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.annotations.WithConverter
import de.scheidgen.xraw.apis.twitter.converter.TwitterDateConverter
import java.util.Date
import de.scheidgen.xraw.annotations.Name
import de.scheidgen.xraw.annotations.JSON

@JSON
class TwitterDirectMessage {
	@WithConverter(TwitterDateConverter) Date created_at
	TwitterStatusEntities entities        
	@Name("id_str") String id        
	TwitterUser recipient
	String recipient_screen_name
	TwitterUser sender
	String sender_screen_name
	String text
}