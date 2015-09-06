package de.scheidgen.social.twitter.converter

import de.scheidgen.social.annotations.Converter

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
	override convert(String value) {
		return new TwitterColor(value)
	}
}