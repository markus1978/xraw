package de.scheidgen.xraw.json

import org.json.JSONObject

class AbstractJSONWrapper {
	protected val JSONObject json

	new(JSONObject json) {
		this.json = json
	}
	
	new() {
		this.json = new JSONObject
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

}