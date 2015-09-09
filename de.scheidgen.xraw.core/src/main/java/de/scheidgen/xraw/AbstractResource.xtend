package de.scheidgen.xraw

import org.json.JSONObject

class AbstractResource {
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

}