package de.scheidgen.xraw.http

import com.github.scribejava.core.model.OAuthRequest
import com.github.scribejava.core.model.Verb
import com.mashape.unirest.http.HttpMethod
import com.mashape.unirest.http.HttpResponse
import com.mashape.unirest.request.HttpRequest
import de.scheidgen.xraw.annotations.AddConstructor
import de.scheidgen.xraw.core.XRawHttpMethod
import de.scheidgen.xraw.core.XRawHttpRequest
import de.scheidgen.xraw.core.XRawHttpResponse
import de.scheidgen.xraw.server.JsonOrgArray
import de.scheidgen.xraw.server.JsonOrgObject
import com.github.scribejava.core.oauth.OAuthService
import com.mashape.unirest.request.HttpRequestWithBody

class UnirestHttpRequest extends XRawHttpRequest {	
	
	new(XRawHttpMethod method, String url) {
		super(method, url)
	}
	
	private static def HttpMethod toUnirest(XRawHttpMethod method) {
		HttpMethod.values.get(method.ordinal)
	}
	
	/**
	 * Convenience method. @return A new equivalent unirest HttpRequest object.
	 */
	def toUnirest() {
		val result = if (body != null) {
			new HttpRequestWithBody(method.toUnirest, url)
		} else {
			new HttpRequest(method.toUnirest, url)
		}
		result.queryString(queryString)
		result.headers(headers)	
		return result
	}
	
	private static def toVerb(XRawHttpMethod method) {
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
	def toScribe(OAuthService service) {
		val result = new OAuthRequest(method.toVerb, url, service)
		headers.forEach[key,value|result.addHeader(key,value)]
		queryString.forEach[key,value|result.addQuerystringParameter(key, value.toString)]
		if (body != null) {
			result.bodyContents		
		}
		return result;
	}
}

@AddConstructor
class UnirestHttpResponse implements XRawHttpResponse {
	val HttpResponse<String> source
	
	override getBodyJSONArray(String key) {
		if (key == null || key == "") {
			new JsonOrgArray(body)
		} else {
			new JsonOrgObject(body).getJSONArray(key)
		}
	}
	
	override getBodyJSONObject(String key) {
		if (key == null || key == "") {
			new JsonOrgObject(body)
		} else {
			new JsonOrgObject(body).getJSONObject(key)
		}
	}
	
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

