package de.scheidgen.xraw.core

import de.scheidgen.xraw.annotations.AddConstructor

@AddConstructor
abstract class AbstractService {
	protected val XRawHttpService _httpService
}