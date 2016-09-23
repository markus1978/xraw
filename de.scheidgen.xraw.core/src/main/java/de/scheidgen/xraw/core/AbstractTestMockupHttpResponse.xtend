package de.scheidgen.xraw.core

import de.scheidgen.xraw.json.JSONArray
import de.scheidgen.xraw.json.JSONObject
import java.util.Map

abstract class AbstractTestMockupHttpResponse implements XRawHttpResponse {
	
	var code = 200
	val Map<String,String> headers = newHashMap
	var Object jsonBody = null
		
	abstract def JSONObject createNewJsonObject()
	abstract def JSONArray createNewJsonArray()
	
	override getBodyJSONObject(String key) {
		if (key != null && key != "") {
			if (jsonBody == null) {
				val bodyObject = createNewJsonObject()
				bodyObject.put(key, createNewJsonObject)
				jsonBody = bodyObject
			}
			return (jsonBody as JSONObject).getJSONObject(key)			
		} else {
			if (jsonBody == null) {
				jsonBody = createNewJsonObject
			}
			return jsonBody as JSONObject			
		}
	}
	
	override getBodyJSONArray(String key) {
		if (key != null && key != "") {
			if (jsonBody == null) {
				val bodyObject = createNewJsonObject()
				bodyObject.put(key, createNewJsonArray)
				jsonBody = bodyObject
			}
			return (jsonBody as JSONObject).getJSONArray(key)	
		} else {
			if (jsonBody == null) {
				jsonBody = createNewJsonArray
			}
			return jsonBody as JSONArray
		}
	}
	
	override getBody() {
		return jsonBody?.toString
	}
	
	override getHeaders() {
		headers
	}
	
	def void setStatus(int code) {
		this.code = code
	}
	
	override getStatus() {
		return code
	}
	
	override getStatusText() {
		return '''«code»'''
	}
	
}