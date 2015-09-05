package de.scheidgen.social.twitter.search

import de.scheidgen.social.core.annotations.Request
import de.scheidgen.social.twitter.resources.TwitterSearchResult
import org.scribe.model.Verb
import de.scheidgen.social.core.annotations.Required

enum SearchResultType {
	mixed, recent, popular
}

@Request(method=Verb.GET, url="https://api.twitter.com/1.1/search/tweets.json", returnType=TwitterSearchResult)
class Tweets {
	/**
	 * A UTF-8, URL-encoded search query of 500 characters maximum, including operators. Queries may additionally be limited by complexity.
	 */
	@Required String q

	/**
	 * Returns tweets by users located within a given radius of the given latitude/longitude. The location is preferentially taking from the Geotagging API, but will fall back to their Twitter profile. The parameter value is specified by “latitude,longitude,radius”, where radius units must be specified as either “mi” (miles) or “km” (kilometers). Note that you cannot use the near operator via the API to geocode arbitrary locations; however you can use this geocode parameter to search near geocodes directly. A maximum of 1,000 distinct “sub-regions” will be considered when using the radius modifier.
	 */
	String geocode

	/**
	 * Restricts tweets to the given language, given by an ISO 639-1 code. Language detection is best-effort.
	 */
	String lang

	/**
	 * Specify the language of the query you are sending (only ja is currently effective). This is intended for language-specific consumers and the default should work in the majority of cases.
	 */
	String locale

	/**
	 * Specifies what type of search results you would prefer to receive. The current default is “mixed.” Valid values include:
  	 *  - mixed: Include both popular and real time results in the response.
     *  - recent: return only the most recent results in the response
     *  - popular: return only the most popular results in the response.
	 */
	SearchResultType result_type

	/**
	 * The number of tweets to return per page, up to a maximum of 100. Defaults to 15. This was formerly the “rpp” parameter in the old Search API.
	 */
	int count

	/**
	 * Returns tweets created before the given date. Date should be formatted as YYYY-MM-DD. Keep in mind that the search index has a 7-day limit. In other words, no tweets will be found for a date older than one week.
	 */
	String until

	/**
	 * Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available.
	 */
	String since_id

	/**
	 * Returns results with an ID less than (that is, older than) or equal to the specified ID.
	 */
	String max_id

	/**
	 * The entities node will be disincluded when set to false.
	 */
	boolean include_entities

	/**
	 * If supplied, the response will use the JSONP format with a callback of the given name. The usefulness of this parameter is somewhat diminished by the requirement of authentication for requests to this endpoint.
	 * Example Values: processTweets
	 */
	String callback	
}