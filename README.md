# XRaw
If you, as a Java programmer, think that plain JSON is just not type-safe enough, or that Jackson and co are just to heavy and stiff to be compatible with your Scala or Xtend coding style, you should read on.

XRaw provides a set of active annotations that simplifies the development of type-safe Java wrapper and converter for JSON data, RESTful API calls, google cloud store entities, Java Beans and more. Providing helpful features to create social media aware apps and Java backends and GWT frontends with Xtend.

[Active annotations](http://www.eclipse.org/xtend/documentation/204_activeannotations.html) are an [Xtend](http://www.eclipse.org/xtend/index.html) feature that allows us to semantically enrich simple data objects declarations with functionality that transparantly (un-)marshalles Java to JSON data, encodes REST requests, etc.

## JSON example
The following small Xtend file demonstrates the use of XRaw annotations to create wrapper-types for some typical JSON data:
```scala
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

Based on this data description, we can now simply use the class Library to wrap corresponing JSON data into Java POJOs:
```
val library = new Library(new JSONObject('''{
  books : [
    {
      title: "Pride and Prejudice",
      authors: "Jane Austin",
      isbn: "96-2345-33123-32"
      publish_date: "1813-04-12T12:00:00Z"
    },
    {
      title: "SAP business workflow",
      authors: "Ulrich Mende, Andreas Berthold",
      
    }
  ]
  adress: "Unter den Linden 6, 1099 Berlin, Germany"
  count: 2
}'''))
```

For example, we can use Xtend to find all "old" books:
```scala
val oldBooks = library.books.filter[it.publishDate.year < 1918]
```

Since xText compiles to Java, we can also use the wrapper types in Java programs:
```java
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

// Use Xtend and its iterable extensions to navigate the results.
userTimelineResult.filter[it.retweetCount > 4].forEach[
	println(it.text)
]	

// Or as a "one liner".
twitter.statuses.userTimeline.trimUser(true).count(100).xResult
    .filter[it.retweetCount > 4].forEach[println(it.text)]
```
This is written in Xtend. You could also use Scala, Java or any other JVM/bytecode based language.

## GWT Support
XRaw is compatible with GWT and its limitations. Just use the GWT libraries Xraw.gwt.xml adn XrawApi.gwt.xml. Since blocking request in thread less Javascript is what you want, XRaw REST request provide a promise-style API for asynchronous calls:

```scala
twitter.statuses.userTimeline.trimUser(true).count(100).xPromiseResult.onResolve[
    it.forEach[log(user.screenName + ": " + text)]
] 
```

## More Wrapper
Usually we need to represent data in different forms and have to transform data between them. From entities to beans to JSON and back again. Besides JSON, Xraw provides wrapper for Java beans and google cloud store entities, as well as some convenience methods to translate between them. You specify your data types once and simply add different annotations to generate the corresponding wrapper:

```scala
@JSON 
@Entity
@Bean
class Book {
  String title
  String isbn
  List<String> authors
  @WithConverter(UtcDateConverter) Date publish_date
}
```

## Get started
The project does contain three modules: xraw, xraw.apis and xraw.examples. Simply compile and install the first two. Look at the [examples](https://github.com/markus1978/xraw/tree/master/de.scheidgen.xraw.examples/src/main/java/de/scheidgen/xraw/examples).
```
git clone git@github.com:markus1978/xraw.git xraw
cd xraw
mvn install
cd ../xraw.apis
mvn install
```



## Status
XRaw is already used by some of my projects. The API is somewhat stable. XRaw is not available via maven central yet.

## Contribute
I need you to try XRaw, check the existing snippets of API (we have some twitter, facebook, youtube, twitch, tumblr). Tell me what works, what doesn't. What annotations do you need.
