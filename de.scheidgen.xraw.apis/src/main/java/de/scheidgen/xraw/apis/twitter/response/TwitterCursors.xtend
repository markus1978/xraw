package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.annotations.Response;
import de.scheidgen.xraw.annotations.Name
import java.util.List

@Response
public class TwitterIdCursor {
	@Name("previous_cursor_str") String previous_cursor
	@Name("next_cursor_str") String next_cursor
	List<String> ids
}

@Response
public class TwitterUserCursor {
	@Name("previous_cursor_str") String previous_cursor
	@Name("next_cursor_str") String next_cursor
	List<TwitterUser> users
}