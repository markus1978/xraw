package de.scheidgen.xraw.apis.twitter.converter

import com.google.gwt.i18n.shared.DateTimeFormat
import com.google.gwt.i18n.shared.DefaultDateTimeFormatInfo
import de.scheidgen.xraw.json.Converter
import java.util.Date

class TwitterDateConverter implements Converter<Date> {	
	override Date toValue(String value) {
		val pattern = "EEE MMM dd HH:mm:ss ZZZZZ yyyy" 
		val info = new DefaultDateTimeFormatInfo()
		val dtf = new DateTimeFormat(pattern, info) {}
		
		return dtf.parse(value);
	}
	
	override toString(Date value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}