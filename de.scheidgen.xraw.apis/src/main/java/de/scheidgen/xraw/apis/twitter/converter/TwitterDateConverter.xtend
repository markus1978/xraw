package de.scheidgen.xraw.apis.twitter.converter

import com.google.gwt.i18n.shared.DateTimeFormat
import de.scheidgen.xraw.json.Converter
import java.util.Date
import com.google.gwt.i18n.shared.DefaultDateTimeFormatInfo

class TwitterDateConverter implements Converter<Date> {
	
	override Date toValue(String value) {
		// Twitter put week day (EEE) in front of data, GWT formatter throws exception when parsing days. Omitting week day.
		val pattern = "MMM dd HH:mm:ss ZZZZ yyyy" 
		val info = new DefaultDateTimeFormatInfo()
		val format = new DateTimeFormat(pattern, info) {}
		return format.parse(value.substring(4))
	}
	
	override String toString(Date value) {
			// Twitter put week day (EEE) in front of data, GWT formatter throws exception when parsing days. Omitting week day.
		val pattern = "MMM dd HH:mm:ss ZZZZ yyyy" 
		val info = new DefaultDateTimeFormatInfo()
		val format = new DateTimeFormat(pattern, info) {}	
		return "Mon " + format.format(value)
	}

}