package de.scheidgen.xraw

import de.scheidgen.xraw.util.AddConstructor
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration
import de.scheidgen.xraw.http.XRawHttpService

@AddConstructor
abstract class AbstractService {
	protected val XRawHttpService _httpService
	
	new(XRawHttpServiceConfiguration httpServiceConfig) {
		_httpService = createService(httpServiceConfig)
	}
	
	protected def XRawHttpService createService(XRawHttpServiceConfiguration httpServiceConfig) {
		throw new UnsupportedOperationException("Not implemented.")
	}
}