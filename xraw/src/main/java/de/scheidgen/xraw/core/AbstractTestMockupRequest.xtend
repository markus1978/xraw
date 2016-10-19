package de.scheidgen.xraw.core

abstract class AbstractTestMockupRequest<Result> {	
		
	def boolean xMatches(XRawHttpRequest httpRequest)	

	final def void xAsyncExecute(XRawHttpRequest request, XRawHttpResponse emptyResponse, (XRawHttpResponse)=>void handler) {		
		xExecute(request, emptyResponse)
		handler.apply(emptyResponse)			
	}
	
	abstract def void xExecute(XRawHttpRequest it, XRawHttpResponse response) 
}
