package de.scheidgen.xraw.core

import de.scheidgen.xraw.util.AddConstructor
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration
import de.scheidgen.xraw.http.XRawHttpService

@AddConstructor
abstract class AbstractService {
	protected val XRawHttpService _httpService
}