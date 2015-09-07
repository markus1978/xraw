# XRaw
Easy development of RESTful API wrapper for Java with xTend.

## quick example
This is a simple script written based on a Twitter API wrapper generated with XRaw.
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
This is written in xTend. You could also use Scala, Java or any other JVM/bytecode based language.

## how does it work
XRaw uses a library of "active" annotations. These allow you to specify the REST API very easily and generates all necessary wrapper Java code for you. You simply write annotated classes with fields that correspond to REST resources and their parameters (@Request), as well as their JSON responses (@Response).
```scala
@Request(method=Verb.GET,
	url="https://api.twitter.com/1.1/search/tweets.json",
	returnType=TwitterSearchResult)
class Tweets {
	/**
	 * A UTF-8, URL-encoded search query of 500 characters maximum, including
	 * operators. Queries may additionally be limited by complexity.
	 */
	@Required String q

	/**
	 * Returns tweets by users located within a given radius of the given latitude/
	 * longitude. The location is preferentially taking from the Geotagging API, but 
         * will fall back to their Twitter profile. 
	 */
	String geocode

	/**
	 * Restricts tweets to the given language, given by an ISO 639-1 code. Language 
         * detection is best-effort.
	 */
	String lang
	...
}
```

```scala
@Response
class TwitterSearchResult {
	List<TwitterStatus> statuses
	TwitterSearchMetaData search_metadata
}

@Response
class TwitterSearchMetaData {	
    @Name("since_id_str") String since_id
    @Name("max_id_str") String max_id
    @Name("refresh_url") String refresh_url_parameters
    @Name("next_results") String next_results_url_parameters
    int count
    double completed_in
    String query
}

@Response
class TwitterStatus {
    Object coordinates	
    boolean favorited = false
    boolean truncated = false
    @WithConverter(TwitterDateConverter) Date created_at
    @Name("id_str") String id
    Object entities
    @Name("in_reply_to_user_id_str") String in_reply_to_user_id
    Object contributors
    String text
    int retweet_count
    @Name("in_reply_to_status_id_str") String in_reply_to_status_id
    Object geo
    boolean retweeted = false
    boolean possibly_sensitive = false
	Object place
    TwitterUser user
    String in_reply_to_screen_name
    String source
}
```
These API classes have to be written in xTend in order for xTend's active annotations to work. XTend is a language that compiles to Java and its active annotations allow you to manipulate the code generation process. Therefore these annotations allow as to add additional semantics to classes and their fields that realize the wrapper functionality.

## get started
```
git clone git@github.com:markus1978/xraw.git xraw
cd xraw/de.scheidgen.xraw/
mvn compile
```

