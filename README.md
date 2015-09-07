# xraw
Easy development of RESTful API wrapper for Java with xTend.

## quick example
```scala
// initialize Twitter API with user auth. Key store for app and user token,secrets
val twitter = SocialScript::createWithStore("data/store.xmi").serviceWithLogin(Twitter, "markus")

// building and sending a search request to Twitter in one line
val searchResults = twitter.search.tweets.q("Barack Obama").resultType(SearchResultType.popular).send

// easy typesafe result navigation 
for (status: searchResults.statuses.filter[retweetCount > 20]) {
    println("# " + status.retweetCount + ":" + status.text)
}
```

## how does it work
XRaw uses a library of "active" annotations. These allow you to specify the REST API very easily and generates all necessary wrapper code for you.
```scala
@Request(method=Verb.GET,
	url="https://api.twitter.com/1.1/search/tweets.json",
	returnType=TwitterSearchResult)
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
	...
```
```scala
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
```

## get started
```
git clone git@github.com:markus1978/xraw.git xraw
cd xraw/de.scheidgen.xraw/
mvn compile
```

