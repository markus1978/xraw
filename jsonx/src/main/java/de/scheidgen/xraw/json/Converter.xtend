package de.scheidgen.xraw.json

import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date

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

class DateConverter implements Converter<Date> {
	
	override toValue(String str) {
		new Date(Long.parseLong(str))
	}
	
	override toString(Date value) {
		Long.toString(value.time)
	}
	
}

class UtcDateConverter implements Converter<Date> {
	
	override toValue(String str) {
		new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").parse(str)
	}
	
	override toString(Date value) {
		new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(value)
	}
	
}