package de.scheidgen.xraw.apis.twitter.converter

import de.scheidgen.xraw.json.Converter
import java.text.SimpleDateFormat
import java.util.Date

class TwitterDateConverter implements Converter<Date> {	
	override Date toValue(String value) {
		return new SimpleDateFormat("EEE MMM dd HH:mm:ss ZZZZZ yyyy").parse(value);
	}
	
	override toString(Date value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}