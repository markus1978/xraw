package de.scheidgen.xraw.json

import java.net.URL

annotation WithConverter {
	Class<? extends Converter<?>> value
}

interface Converter<T> {
	def T toValue(String str)
	def String toString(T value)
}

class UrlConverter implements Converter<URL> {
	
	override toValue(String str) {
		return new URL(str)
	}
	
	override toString(URL value) {
		value.toString
	}
	
}