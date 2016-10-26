package de.scheidgen.xraw.apis.tumblr.converter

import de.scheidgen.xraw.client.json.Converter
import java.util.Date

class TumblrDateConverter implements Converter<Date> {
	override toValue(String value) {
		return new Date(Long.parseLong(value))
	}
	
	override toString(Date value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}