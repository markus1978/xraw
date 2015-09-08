package de.scheidgen.xraw

import org.json.JSONArray
import org.json.JSONObject
import org.scribe.model.Response

class DefaultResponse {
	val Response scribeResponse
	new (Response scribeResponse) {
		this.scribeResponse = scribeResponse
	}
	
	public def isSuccessful() {
		return scribeResponse.successful
	}
	
	public def getHeaders() {
		return scribeResponse.headers
	}
	
	public def getCode() {
		return scribeResponse.code
	}
	
	public def JSONArray getJSONArray(String key) {
		if (scribeResponse.successful) {
			if (key == "") {
				return new JSONArray(scribeResponse.body)
			} else {
				return new JSONObject(scribeResponse.body).getJSONArray(key)
			}
		} else {
			return null
		}
	}
	
	public def JSONObject getJSONObject(String key) {
		if (scribeResponse.successful) {
			if (key == "") {
				return new JSONObject(scribeResponse.body)
			} else {
				return new JSONObject(scribeResponse.body).getJSONObject(key)
			}
		} else {
			return null
		}
	}
	
	override toString() {
		val builder = new StringBuilder
		builder.append(code + ": " + if (successful) "Success" else "Failure")
		for(header: headers.entrySet) {
			builder.append(header.key + ": " + header.value)
		}
		builder.append(scribeResponse.body)
		return builder.toString
	}
}