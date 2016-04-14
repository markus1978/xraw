package de.scheidgen.xraw.examples

import de.scheidgen.xraw.annotations.JSON
import de.scheidgen.xraw.annotations.Name
import de.scheidgen.xraw.annotations.WithConverter
import de.scheidgen.xraw.json.JSONObject
import de.scheidgen.xraw.json.UtcDateConverter
import java.util.Date
import java.util.List

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

class LibraryTest {
	
	def void main(String[] args) {
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
		
		val oldBooks = library.books.filter[it.publishDate.year < 1918]
	}
}