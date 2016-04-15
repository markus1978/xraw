package de.scheidgen.xraw.core

import de.scheidgen.xraw.util.AddConstructor

@AddConstructor
abstract class AbstractService {
	protected val XRawHttpService _httpService
}