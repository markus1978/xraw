package de.scheidgen.xraw.http

import com.mashape.unirest.request.HttpRequest
import java.util.Map

/**
 * XRawScript uses user provided XRawHttpServices to execute REST API calls. 
 * It is the responsibility of these services to manage all authentication
 * related "stuff". If possibly implementing classes can use the given unirest
 * HttpRequest directly or create new request in other libraries and take the
 * data from the given requests. Implementing classes are free to execute
 * other request beforehand (e.g. a OAuth flow).  
 */
interface XRawRestService {
	def XRawHttpResponse synchronousRestCall(HttpRequest unirestRequest) throws XRawHttpException
}

/**
 * Simple HTTP response interface. Is a subset of unirest's HttpResponse<String>'s public interface.
 */
interface XRawHttpResponse {
	def String getBody()

	def Map<String, String> getHeaders()

	def int getStatus()

	def String getStatusText()
}

class XRawHttpException extends Exception {

	new(String message) {
		super(message)
	}

	new(String message, Throwable cause) {
		super(message, cause)
	}

}


