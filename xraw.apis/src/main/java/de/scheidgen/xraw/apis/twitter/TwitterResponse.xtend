package de.scheidgen.xraw.apis.twitter

import de.scheidgen.xraw.annotations.AddConstructor
import de.scheidgen.xraw.annotations.JSON
import de.scheidgen.xraw.client.core.DefaultResponse
import java.util.ArrayList
import java.util.List

@AddConstructor
class TwitterResponse extends DefaultResponse {
	
	private def getIntegerHeader(String name) {
		val valueStr = headers.get(name.toLowerCase)
		if (valueStr != null && valueStr.trim != "") {
			return Long.parseLong(valueStr)	
		} else {
			return Long.MAX_VALUE
		}					
	}
	
	def getRateLimitLimit() {
		return getIntegerHeader("X-Rate-Limit-Limit".toLowerCase)		
	}
	
	def getRateLimitRemaining() {
		return getIntegerHeader("X-Rate-Limit-Remaining".toLowerCase)			
	}
	
	def getRateLimitReset() {
		return getIntegerHeader("X-Rate-Limit-Reset".toLowerCase)		
	}
	
	def isRateLimitExeeded() {
		return !successful && code == 429
	}
	
	def List<TwitterError> getErrors() {
		if (successful) {
			return null
		} else {
			val body = getBody()
			if (body != null) {
				val errorJsonArray = getJSONObject(null).getJSONArray("errors")
				val result = new ArrayList<TwitterError>()
				for (i: 0..<errorJsonArray.length) {
					result.add(new TwitterError(errorJsonArray.getJSONObject(i)))
				}
				return result
			} else {
				return null
			}
		}
	}
}

@JSON class TwitterError {
	int code
	String message
}