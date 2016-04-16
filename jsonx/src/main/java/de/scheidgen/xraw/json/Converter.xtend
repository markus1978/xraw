package de.scheidgen.xraw.json

import com.google.gwt.i18n.shared.DateTimeFormat
import com.google.gwt.i18n.shared.DefaultDateTimeFormatInfo
import java.util.Date

interface Converter<T> {
	def T toValue(String str)
	def String toString(T value)
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
		val pattern = "yyyy-MM-dd'T'HH:mm:ss'Z'" 
		val info = new DefaultDateTimeFormatInfo()
		val dtf = new DateTimeFormat(pattern, info) {}
		
		return dtf.parse(str)
	}
	
	override toString(Date value) {
		val pattern = "yyyy-MM-dd'T'HH:mm:ss'Z'" 
		val info = new DefaultDateTimeFormatInfo()
		val dtf = new DateTimeFormat(pattern, info) {}
		
		return dtf.format(value)
	}
	
}