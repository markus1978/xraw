package de.scheidgen.xraw.client.core

abstract class AbstractService {
	protected val XRawHttpService _httpService

	new(XRawHttpService httpService) {
		this._httpService = httpService
	}
}