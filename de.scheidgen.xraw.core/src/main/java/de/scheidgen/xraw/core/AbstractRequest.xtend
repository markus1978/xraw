package de.scheidgen.xraw.core

import de.scheidgen.xraw.util.Async.Promise
import de.scheidgen.xraw.util.Async
import de.scheidgen.xraw.annotations.AddSuperConstructors
import de.scheidgen.xraw.json.XObject

@AddSuperConstructors
class XrawRestException extends RuntimeException {
	
}

abstract class AbstractRequest<ResponseType extends DefaultResponse, ResourceType> {
	
	private val XRawHttpService service
	private val XRawHttpRequest httpRequest
	
	private var (ResponseType)=>void onError = null
	private var ResponseType response = null
	private var boolean executed = false

	protected new(XRawHttpService service, XRawHttpRequest request) {
		this.service = service;
		httpRequest = request
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
	
	public def <R extends AbstractRequest<? extends DefaultResponse,?>> xCheck() {
		if (!xResponse.successful) {
			println("Api error: " + xResponse.code)
			println("Request: " + httpRequest.url + "?" + httpRequest.queryString.entrySet.join("&")[
				it.key + "=" + it.value
			])
			println(xResponse.getJSONObject("").toString(4))
			throw new RuntimeException("Abort")
		}
		return this
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
	
	public def xPutBody(String value) {
		httpRequest.body = value
	}
	
	public def xPutBody(XObject object) {
		xPutBody(object.xJson.xNative.toString)
	}
	 
	public def xPutQueryStringParameter(String name, String value) {
		httpRequest.queryString.put(name, value)
	}
	
	public def xIsSetQueryStringParameter(String name) {
		return xGetQueryStringParameter(name) != null
	}
	
	public def xGetQueryStringParameter(String name) {
		return httpRequest.queryString.get(name)
	}
	
	public def xSetMethod(XRawHttpMethod method) {
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
	
	public def xOnError((ResponseType)=>void onError) {
		this.onError = onError	
		return this
	}

	/**
	 * Executes the request.
	 */
	public def AbstractRequest<ResponseType, ResourceType> xExecute() {
		validateConstraints
		
		if (response != null) {
			throw new IllegalStateException("This request was already executed. Either reset it or create a new one.")
		} 
			
		val httpResponse = service.synchronousRestCall(httpRequest);
		response = createResponse(httpResponse)
		executed = true
		return this;
	}
	
	public def void xAsyncResult((ResourceType)=>void action) {
		xAsyncExecute[action.apply(xResult)]
	}
	
	public def void xAsyncExecute((ResponseType)=>void action) {
		validateConstraints
		
		if (executed || response != null) {
			throw new IllegalStateException("This request was already executed. Either reset it or create a new one.")
		} else {
			executed = true
		}
					
		service.asynchronousRestCall(httpRequest) [
			val response = createResponse(it)
			this.response = response
			if (response.successful) {
				if (action != null) {
					action.apply(response)
				}	
			} else {
				if (onError != null) {
					onError.apply(response)
				}
			}			
		]
	}
	
	public def Promise<ResourceType> xPromiseResult() {
		Async.promise[p|xOnError[p.reject(response.error)].xAsyncResult[p.resolve(it)]]
	}
	
	public def Promise<ResponseType> xPromiseResponse() {
		Async.promise[p|xOnError[p.reject(response.error)].xAsyncExecute[p.resolve(it)]]
	}
}