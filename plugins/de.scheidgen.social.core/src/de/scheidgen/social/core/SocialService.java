package de.scheidgen.social.core;

import java.util.Optional;
import java.util.Scanner;

import org.scribe.builder.ServiceBuilder;
import org.scribe.builder.api.Api;
import org.scribe.model.OAuthRequest;
import org.scribe.model.Response;
import org.scribe.model.Token;
import org.scribe.model.Verb;
import org.scribe.model.Verifier;
import org.scribe.oauth.OAuthService;

import de.scheidgen.social.core.socialstore.Profile;
import de.scheidgen.social.core.socialstore.ServiceCredentials;
import de.scheidgen.social.core.socialstore.SocialStoreFactory;

public class SocialService {
	
	private final OAuthService oAuthService;
	private final Token accessToken;

	public static SocialService authenticate(Profile profile, final Class<? extends Api> scribeServiceClass, String apiKey, String apiSecret, String callbackURL) {
		ServiceBuilder serviceBuilder = new ServiceBuilder().provider(scribeServiceClass)
				.apiKey(apiKey)
				.apiSecret(apiSecret);
		
		if (callbackURL != null) {
			serviceBuilder.callback(callbackURL);
		}
		
		OAuthService service = serviceBuilder.build();
		
		Optional<ServiceCredentials> credentialOptional = profile.getServices().stream().filter((ServiceCredentials credentials) -> {
			return credentials.getScribeServiceClass() == scribeServiceClass;
		}).findFirst();
		
		if (credentialOptional.isPresent()) {
			ServiceCredentials credential = credentialOptional.get();
			Token accessToken = new Token(credential.getAccessToken(), credential.getSecret());
			return new SocialService(service, accessToken);
		} else {
			@SuppressWarnings("resource")
			Scanner in = new Scanner(System.in);

			System.out.println("=== " + scribeServiceClass.getSimpleName() + "'s OAuth Workflow ===");
			System.out.println();

			// Obtain the Request Token
			System.out.println("Fetching the Request Token...");
			Token requestToken = service.getRequestToken();
			System.out.println("Got the Request Token!");
			System.out.println();

			System.out.println("Now go and authorize Scribe here:");
			System.out.println(service.getAuthorizationUrl(requestToken));
			System.out.println("And paste the verifier here");
			System.out.print(">>");
			Verifier verifier = new Verifier(in.nextLine());
			System.out.println();

			// Trade the Request Token and Verfier for the Access Token
			System.out.println("Trading the Request Token for an Access Token...");
			Token accessToken = service.getAccessToken(requestToken, verifier);
			System.out.println("Got the Access Token!");
			System.out.println("(if you're curious, it looks like this: " + accessToken + " )");
			System.out.println();

			ServiceCredentials credentials = SocialStoreFactory.eINSTANCE.createServiceCredentials();
			credentials.setAccessToken(accessToken.getToken());
			credentials.setSecret(accessToken.getSecret());
			credentials.setScribeServiceClass(scribeServiceClass);
			
			profile.getServices().add(credentials);

			return new SocialService(service, accessToken);
		}
	}

	public SocialService(OAuthService oAuthService, Token accessToken) {
		super();
		this.oAuthService = oAuthService;
		this.accessToken = accessToken;
	}
	
	public Response execute(OAuthRequest request) {
		oAuthService.signRequest(accessToken, request);
		System.out.println("*** " + request.getCompleteUrl());
		return request.send();
	}
	
	public String get(String url) {
		return execute(new OAuthRequest(Verb.GET, url)).getBody();
	}
}
