package de.scheidgen.social.annotations

import de.scheidgen.social.core.SocialService

class AbstractApi {
	protected val SocialService service;
	protected new(SocialService service) {
		this.service = service;
	}
}