package de.scheidgen.social.twitter.converter

import de.scheidgen.social.annotations.Converter
import java.text.SimpleDateFormat
import java.util.Date

class TwitterDateConverter implements Converter<Date> {	
	override Date convert(String value) {
		return new SimpleDateFormat("EEE MMM dd HH:mm:ss ZZZZZ yyyy").parse(value);
	}	
}