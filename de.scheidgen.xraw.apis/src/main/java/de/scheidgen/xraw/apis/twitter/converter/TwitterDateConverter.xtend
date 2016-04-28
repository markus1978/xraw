package de.scheidgen.xraw.apis.twitter.converter

import com.google.gwt.i18n.client.DateTimeFormat
import de.scheidgen.xraw.json.Converter
import java.util.Date

class TwitterDateConverter implements Converter<Date> {	
	override Date toValue(String value) {
		val pattern = "MMM dd HH:mm:ss ZZZZ yyyy" 
		val format = DateTimeFormat.getFormat(pattern)
		
		// Twitter put week day (EEE) in front of data, GWT formatter throws exception when parsing days. Omitting week day.
		return format.parse(value.substring(4));
	}
	
	override toString(Date value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}