package de.scheidgen.social.core.annotations

import java.net.URL

annotation WithConverter {
	Class<? extends Converter<?>> value
}

interface Converter<T> {
	def T convert(String value)
}

class UrlConverter implements Converter<URL> {
	override convert(String value) {
		return new URL(value)
	}
}