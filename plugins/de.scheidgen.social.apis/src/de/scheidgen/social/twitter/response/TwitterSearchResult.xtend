package de.scheidgen.social.twitter.response

import de.scheidgen.social.annotations.Name
import de.scheidgen.social.annotations.Response
import java.util.List

@Response
class TwitterSearchResult {
	List<TwitterStatus> statuses
	TwitterSearchMetaData search_metadata
}

@Response
class TwitterSearchMetaData {	
    @Name("since_id_str") String max_id
    @Name("max_id_str") String since_id
    @Name("refresh_url") String refresh_url_parameters
    @Name("next_results") String next_results_url_parameters
    int count
    double completed_in
    String query
}