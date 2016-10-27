package de.scheidgen.xraw.apis.twitter.converter

import de.scheidgen.xraw.client.json.Converter

class TwitterColor {
	public val int r
	public val int g
	public val int b
	
	protected new(String string) {
		r = Integer::parseInt("0x" + string.substring(0, 2))
		g = Integer::parseInt("0x" + string.substring(2, 4))
		b = Integer::parseInt("0x" + string.substring(4, 6))
	}
	
	override toString() {
		return "rgb(" + r + "," + g + "," + b + ")"
	}
	
}

class TwitterColorConverter implements Converter<TwitterColor> {
	override toValue(String value) {
		return new TwitterColor(value)
	}
	
	override toString(TwitterColor value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}