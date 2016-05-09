package de.scheidgen.xraw.core

import com.google.gwt.user.client.Timer

abstract class AbstractTestMockupRequest<Result> {	
		
	def boolean xMatches(XRawHttpRequest httpRequest)	

	final def void xAsyncExecute(XRawHttpRequest request, XRawHttpResponse emptyResponse, (XRawHttpResponse)=>void handler) {
		val Timer timer = [
			xExecute(request, emptyResponse)
			handler.apply(emptyResponse)
		]
		timer.schedule(1)
	}
	
	abstract def void xExecute(XRawHttpRequest it, XRawHttpResponse response) 
}
