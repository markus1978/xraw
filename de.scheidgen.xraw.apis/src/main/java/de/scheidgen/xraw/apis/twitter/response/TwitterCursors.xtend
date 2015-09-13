package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.apis.twitter.converter.TwitterIdConverter
import de.scheidgen.xraw.json.JSON
import de.scheidgen.xraw.json.Name
import de.scheidgen.xraw.json.WithConverter
import java.util.List

@JSON
public class TwitterIdCursor {
	@Name("previous_cursor_str") String previous_cursor
	@Name("next_cursor_str") String next_cursor
	@WithConverter(TwitterIdConverter) List<String> ids
}

@JSON
public class TwitterUserCursor {
	@Name("previous_cursor_str") String previous_cursor
	@Name("next_cursor_str") String next_cursor
	List<TwitterUser> users
}