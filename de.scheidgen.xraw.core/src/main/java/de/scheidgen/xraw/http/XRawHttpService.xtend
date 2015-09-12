package de.scheidgen.xraw.http

import com.mashape.unirest.http.HttpMethod
import com.mashape.unirest.request.HttpRequest
import de.scheidgen.xraw.util.AddConstructor
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.scribe.model.OAuthRequest
import org.scribe.model.Response
import org.scribe.model.Verb
import com.mashape.unirest.http.HttpResponse
import de.scheidgen.xraw.util.AddSuperConstructors

/**
 * XRawScript uses user provided XRawHttpServices to execute REST API calls. 
 * It is the responsibility of these services to manage all authentication
 * related "stuff". Implementing classes are free to execute
 * other request beforehand (e.g. to realize an a OAuth flow).  
 */
interface XRawHttpService {
	def XRawHttpResponse synchronousRestCall(XRawHttpRequest request) throws XRawHttpException
}

class XRawHttpRequest {	
	@Accessors(PUBLIC_GETTER) val Map<String,Object> queryString = newHashMap
	@Accessors(PUBLIC_GETTER) val Map<String,String> headers = newHashMap
	@Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var String url = null
	@Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var HttpMethod method = HttpMethod.GET
	
	new(HttpMethod method, String url) {
		this.method = method
		this.url = url
	}
	
	/**
	 * Convenience method. @return A new equivalent unirest HttpRequest object.
	 */
	def toUnirest() {
		val result = new HttpRequest(method, url)
		result.queryString(queryString)
		result.headers(headers)
		return result
	}
	
	private static def toVerb(HttpMethod method) {
		return switch(method) {
			case GET: Verb.GET
			case POST: Verb.POST
			case PUT: Verb.PUT
			case DELETE: Verb.DELETE
			case OPTIONS: Verb.OPTIONS
			case PATCH: throw new UnsupportedOperationException()
			case HEAD: Verb.HEAD
			default: throw new UnsupportedOperationException() 
		}
	}
	
	/**
	 * Convenience method. @return A new equivalent scribe OAuthRequest object.
	 */
	def toScribe() {
		val result = new OAuthRequest(method.toVerb, url)
		headers.forEach[key,value|result.addHeader(key,value)]
		queryString.forEach[key,value|result.addQuerystringParameter(key, value.toString)]
		return result;
	}
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

@AddConstructor
class ScribeHttpResponse implements XRawHttpResponse {
	val Response source
	
	override getBody() {
		return source.body
	}
	
	override getHeaders() {
		return source.headers
	}
	
	override getStatus() {
		return source.code
	}
	
	override getStatusText() {
		return source.message
	}
}

@AddConstructor
class UnirestHttpResponse implements XRawHttpResponse {
	val HttpResponse<String> source
	
	override getBody() {
		return source.body
	}
	
	override getHeaders() {
		return source.headers.mapValues[join(", ")]
	}
	
	override getStatus() {
		return source.status
	}
	
	override getStatusText() {
		return source.statusText
	}
}

@AddSuperConstructors
class XRawHttpException extends Exception {

}


