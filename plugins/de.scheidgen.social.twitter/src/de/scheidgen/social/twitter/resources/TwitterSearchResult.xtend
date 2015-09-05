package de.scheidgen.social.twitter.resources

import de.scheidgen.social.core.annotations.Response
import java.util.List
import de.scheidgen.social.core.annotations.Name

@Response
class TwitterSearchResult {
	List<TwitterTweet> statuses
	SearchMetaData search_metadata
}

@Response
class SearchMetaData {	
    @Name("since_id_str") String max_id
    @Name("max_id_str") String since_id
    @Name("refresh_url") String refresh_url_parameters
    @Name("next_results") String next_results_url_parameters
    int count
    double completed_in
    String query
}