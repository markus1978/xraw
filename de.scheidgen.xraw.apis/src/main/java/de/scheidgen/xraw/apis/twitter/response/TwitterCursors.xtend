package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.annotations.JSON
import de.scheidgen.xraw.annotations.Name
import de.scheidgen.xraw.annotations.WithConverter
import de.scheidgen.xraw.apis.twitter.converter.TwitterIdConverter
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