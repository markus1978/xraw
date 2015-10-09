# XRaw
XRaw provides a set of active annotations that simplifies the development of type-safe Java wrapper for JSON data, RESTful API calls, and MongoDB interfaces. Providing all necessary features to create social media aware apps and backends.

Active annotations are an xTend feature that allows us to semantically enrich simple data objects declarations with functionality that transparantly (un-)marshalles Java to JSON data, encodes REST requests, or accesses a database.

## JSON example
The following small xTend file demonstrates the use of XRaw annotations to create a wrapper-types for the JSON data of a library:
```
@JSON class Library {
  List<Book> books
  String adress
  @Name("count") int entries
}

@JSON class Book {
  String title
  String isbn
  List<String> authors
  @WithConverter(UtcDateConverter) Date publish_date
}
```
Based on this data description, we can now simply use the class Library to wrap corresponing JSON data into Java POJOs. For example, we can use xTend to find all "old" books:
```
val oldBooks = library.books.filter[it.publishDate.year < 1918]
```
Since xText compiles to Java, we can also use the wrapper types in Java programs:
```
public long coutBooksBefore(Library library, int year) {
  return library.getBooks().stream().filter(book->book.getPublishDate().getYear() < year).count();
}
```

## REST example
This is a simple "script" written based on a Twitter API wrapper created with XRaw.
```scala
// For starters, use XRawScript to interactively create a Twitter instance 
// with a pre-configured HTTPService that deals with all OAuth related issues.
val twitter = XRawScript::get("data/store.json", "markus", Twitter)

// REST API endpoints are structured and accessed via fluent interface
val userTimelineReq = twitter.statuses.userTimeline

// Parameters can also be added fluently.
userTimelineReq.trimUser(true).count(100)

// xResult will execute the request and wrap the returned JSON data.
val userTimelineResult = userTimelineReq.xResult

// Use xTend and its iterable extensions to navigate the results.
userTimelineResult.filter[it.retweetCount > 4].forEach[
	println(it.text)
]	

// Or as a one liner.
twitter.statuses.userTimeline.trimUser(true).count(100).xResult.filter[it.retweetCount > 4].forEach[println(it.text)]
```
This is written in xTend. You could also use Scala, Java or any other JVM/bytecode based language.

## get started
```
git clone git@github.com:markus1978/xraw.git xraw
cd xraw/de.scheidgen.xraw/
mvn compile
```

Look at the example project.

## status
XRaw is early in development. There is no release yet; XRaw is not available via maven central yet.

## features
###JSON
- wrapper for existing JSON data or to create new JSON
- support for primitive values, arrays, objects
- converter to convert complex type to and from string
- different key names in JSON and Java to adopt to existing code

###REST
- wrapper for GET and POST requests
- with URL and body parameters
- with parameters encoded in URL path
- with array and object JSON results
- customizable HTTP implementation, e.g. to integrate with existing signing and OAuth solutions
- customizable respone types, e.g. to use API specific data passed through HTTP header, HTTP status codes, etc.

###MongoDB
- simple databases wrapper for uni-types collections of JSON data

## contribute
I need you to try XRaw, check the existing snippets of API (we have some twitter, facebook, youtube, twitch, tumblr). Tell us what works, what doesn't. What annotations do you need.
