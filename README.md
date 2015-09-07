# xraw
Easy development of RESTful API wrapper for Java with xTend.

## quick example
```scala
val twitter = SocialScript::createWithStore("data/store.xmi").serviceWithLogin(Twitter, "markus")
val searchResults = twitter.search.tweets.q("Barack Obama").resultType(SearchResultType.popular).send
for (status: searchResults.statuses) {
    println("# " + status.retweetCount + ":" + status.text)
}
```

## get started
```
git clone
cd xraw/de.scheidgen.xraw/
mvn compile
```

