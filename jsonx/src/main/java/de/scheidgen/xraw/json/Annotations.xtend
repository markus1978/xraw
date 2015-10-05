package de.scheidgen.xraw.json

import java.net.URL
import org.eclipse.xtend.lib.macro.Active
import java.lang.annotation.Target

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

@Target(METHOD)
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
