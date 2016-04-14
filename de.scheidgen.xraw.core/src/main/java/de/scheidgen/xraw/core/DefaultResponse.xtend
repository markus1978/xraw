package de.scheidgen.xraw.core

import de.scheidgen.xraw.http.XRawHttpResponse
import de.scheidgen.xraw.json.JSONArray
import de.scheidgen.xraw.json.JSONObject

class DefaultResponse {
	val XRawHttpResponse httpResponse
	new (XRawHttpResponse httpResponse) {
		this.httpResponse = httpResponse
	}
	
	public def isSuccessful() {
		return httpResponse.status == 200
	}
	
	public def getHeaders() {
		return httpResponse.headers
	}
	
	public def getCode() {
		return httpResponse.status
	}
	
	public def getBody() {
		return httpResponse.body
	}
	
	public def JSONArray getJSONArray(String key) {
		if (successful) {
			if (key == "") {
				return new JSONArray(httpResponse.body)
			} else {
				return new JSONObject(httpResponse.body).getJSONArray(key)
			}
		} else {
			return null
		}
	}
	
	public def JSONObject getJSONObject(String key) {
		if (successful) {
			if (key == "") {
				return new JSONObject(httpResponse.body)
			} else {
				return new JSONObject(httpResponse.body).getJSONObject(key)
			}
		} else {
			return null
		}
	}
	
	override toString() {
		val builder = new StringBuilder
		builder.append(code + ": " + (if (successful) "Success" else "Failure") + "\n")
		for(header: headers.entrySet) {
			builder.append(header.key + ": " + header.value + "\n")
		}
		builder.append(httpResponse.body)
		return builder.toString
	}
}