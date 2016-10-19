package de.scheidgen.xraw.json

import org.eclipse.xtend.lib.annotations.EqualsHashCode
import jsinterop.annotations.JsMethod

@EqualsHashCode
class XObject {
	protected val JSONObject json

	new(JSONObject json) {
		this.json = json
	}

	public def xGetString(String key) {
		if (json.isNull(key)) {
			return null;
		} else {
			return json.get(key).toString
		}
	}
	
	public def xJson() {
		return json
	}
	
	@JsMethod
	public def xJavaScript() {
		return json.xJavaScript
	}
}
