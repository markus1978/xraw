package de.scheidgen.xraw

import de.scheidgen.xraw.http.XRawRestService
import de.scheidgen.xraw.util.AddConstructor
import de.scheidgen.xraw.script.ServiceConfiguration

@AddConstructor
abstract class AbstractService {
	protected val XRawRestService _httpService
	
	new(ServiceConfiguration httpServiceConfig) {
		_httpService = createService(httpServiceConfig)
	}
	
	protected def XRawRestService createService(ServiceConfiguration httpServiceConfig) {
		throw new UnsupportedOperationException("Not implemented.")
	}
}