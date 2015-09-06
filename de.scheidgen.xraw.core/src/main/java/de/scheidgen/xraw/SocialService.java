package de.scheidgen.xraw;

import org.scribe.model.OAuthRequest;
import org.scribe.model.Response;
import org.scribe.model.Token;
import org.scribe.oauth.OAuthService;

/**
 * Simple wrapper around {@link OAuthService} that uses user credentials if
 * there are provided.
 */
public class SocialService {

	private final OAuthService oAuthService;
	private final Token accessToken;

	public SocialService(OAuthService oAuthService) {
		this(oAuthService, null);
	}
	
	public SocialService(OAuthService oAuthService, Token accessToken) {
		super();
		this.oAuthService = oAuthService;
		this.accessToken = accessToken;
	}

	public Response send(OAuthRequest request) {
		if (accessToken != null) {
			oAuthService.signRequest(accessToken, request);
		}
		return request.send();
	}
}
