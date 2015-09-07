package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.annotations.Response;
import de.scheidgen.xraw.annotations.Name
import java.util.List
import de.scheidgen.xraw.annotations.WithConverter
import de.scheidgen.xraw.apis.twitter.converter.TwitterIdConverter

@Response
public class TwitterIdCursor {
	@Name("previous_cursor_str") String previous_cursor
	@Name("next_cursor_str") String next_cursor
	@WithConverter(TwitterIdConverter) List<String> ids
}

@Response
public class TwitterUserCursor {
	@Name("previous_cursor_str") String previous_cursor
	@Name("next_cursor_str") String next_cursor
	List<TwitterUser> users
}