package de.scheidgen.xraw.apis.twitter

import de.scheidgen.xraw.DefaultResponse
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.Resource
import org.json.JSONObject
import java.util.ArrayList
import java.util.List

class TwitterResponse extends DefaultResponse {
	
	new(org.scribe.model.Response scribeResponse) {
		super(scribeResponse)
	}
	
	def getRateLimitLimit() {
		return Integer.parseInt(headers.get("X-Rate-Limit-Limit".toLowerCase))
	}
	
	def getRateLimitRemaining() {
		return Integer.parseInt(headers.get("X-Rate-Limit-Remaining".toLowerCase))
	}
	
	def getRateLimitReset() {
		return Long.parseLong(headers.get("X-Rate-Limit-Reset".toLowerCase))
	}
	
	def List<TwitterError> getErrors() {
		if (successful) {
			return null
		} else {
			val body = getBody()
			if (body != null) {
				val errorJsonArray = new JSONObject(body).getJSONArray("errors")
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

@Resource class TwitterError {
	int code
	String message
}