package de.scheidgen.xraw.json

import java.net.URL
import org.eclipse.xtend.lib.macro.Active
import java.lang.annotation.Target
import java.util.Date
import java.text.SimpleDateFormat

annotation Name {
	String value
}

@Active(typeof(JSONWrapperCompilationParticipant))
@Target(TYPE)
annotation JSON {

}

@Active(typeof(JSONWrapperCompilationParticipant))
@Target(TYPE)
annotation Resource {
	
}

@Target(FIELD)
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
