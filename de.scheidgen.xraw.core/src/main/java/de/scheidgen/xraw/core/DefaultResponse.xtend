package de.scheidgen.xraw.core

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
	
	public def getError() {
		if (!isSuccessful) {
			return new XrawRestException('''Unsuccessful REST request, response code is «httpResponse.status»: «httpResponse.statusText»''')
		}
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
			return httpResponse.getBodyJSONArray(key)			
		} else {
			return null
		}
	}
	
	public def JSONObject getJSONObject(String key) {
		if (successful) {
			return httpResponse.getBodyJSONObject(key)
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