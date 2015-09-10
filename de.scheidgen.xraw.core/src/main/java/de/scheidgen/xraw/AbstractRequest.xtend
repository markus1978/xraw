package de.scheidgen.xraw

import com.mashape.unirest.http.HttpMethod
import com.mashape.unirest.request.HttpRequest
import de.scheidgen.xraw.http.XRawHttpResponse
import de.scheidgen.xraw.http.XRawRestService
import java.util.Map

abstract class AbstractRequest<ResponseType, ResourceType> {
	
	private val Map<String, String> queryStringParameters = newHashMap
	private var String url = null
	private var HttpMethod method = null
	
	private val XRawRestService service
	private var ResponseType response = null

	protected new(XRawRestService service, HttpMethod method, String url) {
		this.service = service;
		this.url = url
		this.method = method
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
	 *  Attempts to execute this request implicitely if it was not executed yet.
	 */
	public abstract def ResourceType xResult() 
	
	public def xReset() {
		response = null
	}
	
	protected abstract def void validateConstraints()
	protected abstract def ResponseType createResponse(XRawHttpResponse httpResponse)
	
	public def xPutQueryStringParameter(String name, String value) {
		queryStringParameters.put(name, value)
	}
	
	public def xIsSetQueryStringParameter(String name) {
		return xGetQueryStringParameter(name) != null
	}
	
	public def xGetQueryStringParameter(String name) {
		return queryStringParameters.get(name)
	}
	
	public def xSetMethod(HttpMethod method) {
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
		
		if (response != null) {
			throw new IllegalStateException("This request was already executed. Either reset it or create a new one.")
		}
	
		val httpRequest = new HttpRequest(method, url)
		queryStringParameters.entrySet.forEach[httpRequest.queryString(key, value.toString)]		
		val httpResponse = service.synchronousRestCall(httpRequest);
		response = createResponse(httpResponse)
		return this;
	}
}