package de.scheidgen.xraw

import com.mashape.unirest.http.HttpMethod
import de.scheidgen.xraw.http.XRawHttpRequest
import de.scheidgen.xraw.http.XRawHttpResponse
import de.scheidgen.xraw.http.XRawHttpService

abstract class AbstractRequest<ResponseType, ResourceType> {
	
	private val XRawHttpService service
	private val XRawHttpRequest httpRequest
	
	private var ResponseType response = null

	protected new(XRawHttpService service, HttpMethod method, String url) {
		this.service = service;
		httpRequest = new XRawHttpRequest(method, url)
	}

	/**
	 * @return The {@link DefaultResponse} instance that represents the response 
	 * to this request after it was executed. Executes this request implicitly. 
	 */
	public def xResponse() {
		if (response == null) {
			xExecute();
		}
		return response;
	}
	
	/**
	 * 	@return The result of this request. Null if this request was not executed successfully. 
	 *  Attempts to execute this request implicitly if it was not executed yet.
	 */
	public abstract def ResourceType xResult() 
	
	public def xReset() {
		response = null
	}
	
	protected abstract def void validateConstraints()
	protected abstract def ResponseType createResponse(XRawHttpResponse httpResponse)
	
	public def xPutQueryStringParameter(String name, String value) {
		httpRequest.queryString.put(name, value)
	}
	
	public def xIsSetQueryStringParameter(String name) {
		return xGetQueryStringParameter(name) != null
	}
	
	public def xGetQueryStringParameter(String name) {
		return httpRequest.queryString.get(name)
	}
	
	public def xSetMethod(HttpMethod method) {
		httpRequest.method = method
	}
	
	public def xGetMethod() {
		return httpRequest.method
	}
	
	public def xSetUrl(String url) {
		httpRequest.url = url
	}
	
	public def xGetUrl() {
		return httpRequest.url
	}
	
	public def boolean xIsExecuted() {
		return response != null;
	}

	/**
	 * Executes the request.
	 */
	public def AbstractRequest<ResponseType, ResourceType> xExecute() {
		System.out.print(".");
		validateConstraints
		
		if (response != null) {
			throw new IllegalStateException("This request was already executed. Either reset it or create a new one.")
		}
			
		val httpResponse = service.synchronousRestCall(httpRequest);
		response = createResponse(httpResponse)
		return this;
	}
}