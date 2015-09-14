package de.scheidgen.xraw.apis.twitter.response

import de.scheidgen.xraw.json.JSON
import de.scheidgen.xraw.json.Name
import java.util.List

@JSON
class TwitterSearchResult {
	List<TwitterStatus> statuses
	TwitterSearchMetaData search_metadata
}

@JSON
class TwitterSearchMetaData {	
    @Name("since_id_str") String since_id
    @Name("max_id_str") String max_id
    @Name("refresh_url") String refresh_url_parameters
    @Name("next_results") String next_results_url_parameters
    int count
    double completed_in
    String query
}