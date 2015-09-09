package de.scheidgen.xraw

import java.util.Map
import org.scribe.model.OAuthRequest
import org.scribe.model.Response
import org.scribe.model.Verb

abstract class AbstractRequest<ResponseType, ResourceType> {
	
	private val Map<String, String> queryStringParameters = newHashMap
	private var String url = null
	private var Verb method = Verb.GET
	
	protected val SocialService _service
	protected var ResponseType _response = null

	protected new(SocialService service, Verb method, String url) {
		this._service = service;
		this.url = url
		this.method = method
	}

	/**
	 * @return The {@link DefaultResponse} instance that represents the response 
	 * to this request after it was executed. Executes this request implicitly. 
	 */
	public def xResponse() {
		if (_response == null) {
			xExecute();
		}
		return _response;
	}
	
	/**
	 * 	@return The result of this request. Null if this request was not executed successfully. 
	 *  Attempts to execute this request implicitely if it was not executed yet.
	 */
	public abstract def ResourceType xResult() 
	
	public def xReset() {
		_response = null
	}
	
	protected abstract def void validateConstraints()
	protected abstract def ResponseType createResponse(Response scribeResponse)
	
	public def xPutQueryStringParameter(String name, String value) {
		queryStringParameters.put(name, value)
	}
	
	public def xIsSetQueryStringParameter(String name) {
		return xGetQueryStringParameter(name) != null
	}
	
	public def xGetQueryStringParameter(String name) {
		return queryStringParameters.get(name)
	}
	
	public def xSetMethod(Verb method) {
		this.method = method
	}
	
	public def xGetMethod() {
		return this.method
	}
	
	public def xSetUrl(String url) {
		this.url = url
	}
	
	public def xGetUrl() {
		return this.url
	}

	/**
	 * Executes the request.
	 */
	public def AbstractRequest<ResponseType, ResourceType> xExecute() {
		System.out.print(".");
		validateConstraints
		
		if (_response != null) {
			throw new IllegalStateException("This request was already executed. Either reset it or create a new one.")
		}
					
		val OAuthRequest scribeRequest = new OAuthRequest(method, url)
		queryStringParameters.entrySet.forEach[scribeRequest.addQuerystringParameter(key, value.toString)]		
		val Response scribeResponse = _service.send(scribeRequest);
		_response = createResponse(scribeResponse)
		return this;
	}
}