package de.scheidgen.social.tumblr.converter

import de.scheidgen.social.annotations.Converter
import java.util.Date

class TumblrDateConverter implements Converter<Date> {
	override convert(String value) {
		return new Date(Long.parseLong(value))
	}
}