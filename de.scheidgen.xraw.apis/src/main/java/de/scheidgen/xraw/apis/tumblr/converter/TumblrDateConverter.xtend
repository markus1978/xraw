package de.scheidgen.xraw.apis.tumblr.converter

import de.scheidgen.xraw.annotations.Converter
import java.util.Date

class TumblrDateConverter implements Converter<Date> {
	override convert(String value) {
		return new Date(Long.parseLong(value))
	}
}