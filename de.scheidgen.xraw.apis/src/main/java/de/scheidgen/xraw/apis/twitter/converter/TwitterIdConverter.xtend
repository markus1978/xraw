package de.scheidgen.xraw.apis.twitter.converter

import de.scheidgen.xraw.json.Converter

class TwitterIdConverter implements Converter<String> {
	
	override toValue(String value) {
		return value
	}
	
	override toString(String value) {
		return value
	}

}