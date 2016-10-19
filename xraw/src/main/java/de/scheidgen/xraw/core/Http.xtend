package de.scheidgen.xraw.core

import com.google.gwt.http.client.RequestBuilder
import com.google.gwt.http.client.URL
import de.scheidgen.xraw.json.JSONArray
import de.scheidgen.xraw.json.JSONObject
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * XRawScript uses user provided XRawHttpServices to execute REST API calls. 
 * It is the responsibility of these services to manage all authentication
 * related "stuff". Implementing classes are free to execute
 * other request beforehand (e.g. to realize an a OAuth flow).  
 */
interface XRawHttpService {
	def XRawHttpRequest createEmptyRequest(XRawHttpMethod method, String url)
	def XRawHttpResponse synchronousRestCall(XRawHttpRequest request) throws XRawHttpException
	def void asynchronousRestCall(XRawHttpRequest request, (XRawHttpResponse)=>void handler)
}

enum XRawHttpMethod {
	GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS;
}

abstract class XRawHttpRequest {
	@Accessors(PUBLIC_GETTER, PROTECTED_SETTER) val Map<String,Object> queryString = newHashMap
	@Accessors(PUBLIC_GETTER, PROTECTED_SETTER) val Map<String,String> headers = newHashMap
	@Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var String url = null
	@Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var XRawHttpMethod method = XRawHttpMethod.GET
	@Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var String body
	
	protected new(XRawHttpMethod method, String url) {
		this.method = method
		this.url = url
	}
}

/**
 * Simple HTTP response interface. Is a subset of unirest's HttpResponse<String>'s public interface.
 */
interface XRawHttpResponse {
	def JSONObject getBodyJSONObject(String key)
	
	def JSONArray getBodyJSONArray(String key)
	
	def String getBody()

	def Map<String, String> getHeaders()

	def int getStatus()

	def String getStatusText()
}

class XRawHttpException extends Exception {
	new(String msg) {
		super(msg)
	}

	new(String msg, Exception cause) {
		super(msg, cause)
	}
}


class GwtHttpRequest extends XRawHttpRequest {
	new(XRawHttpMethod method, String url) {
		super(method, url)
	}
	
	def RequestBuilder.Method toGwt(XRawHttpMethod method) {
		return switch(method) {
			case GET: RequestBuilder.GET
			case POST: RequestBuilder.POST
			case PUT: RequestBuilder.PUT
			case DELETE: RequestBuilder.DELETE
			case OPTIONS: throw new UnsupportedOperationException()
			case PATCH: throw new UnsupportedOperationException()
			case HEAD: RequestBuilder.HEAD
			default: throw new UnsupportedOperationException() 
		}
	}
	
	def RequestBuilder toGwt() {
		val url = URL.encode('''«url»«IF !queryString.empty»?«FOR entry:queryString.entrySet SEPARATOR "&"»«entry.key»=«entry.value»«ENDFOR»«ENDIF»''')
		val result = new RequestBuilder(method.toGwt, url)
		for (parameter:headers.entrySet) {
			result.setHeader(parameter.key, parameter.value)
		}
		if (body != null) {
			result.requestData = body
		}
		return result
	}
}
