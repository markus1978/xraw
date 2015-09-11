package de.scheidgen.xraw.http

import de.scheidgen.xraw.script.InteractiveServiceConfiguration
import de.scheidgen.xraw.script.ServiceConfiguration
import de.scheidgen.xraw.script.ServiceConfigurationScope
import java.io.Serializable
import org.scribe.builder.ServiceBuilder
import org.scribe.builder.api.Api
import org.scribe.model.SignatureType
import org.scribe.model.Token
import org.scribe.model.Verifier
import org.scribe.oauth.OAuthService

import static de.scheidgen.xraw.script.ServiceConfiguration.*
import static de.scheidgen.xraw.script.ServiceConfigurationScope.*

class ScribeOAuth1Service implements XRawRestService {
	
	val OAuthService httpService
	val Token accessToken
	
	new(Class<? extends Api> apiClass, ServiceConfiguration httpServiceConfiguration) {
		
		val String apiKey = httpServiceConfiguration.getInteractive(true, API, apiKey, "We need your API key:") [it]
		val String apiSecret = httpServiceConfiguration.getInteractive(true, API, apiSecret, "We need your API secret:") [it]
		val String callbackURL = httpServiceConfiguration.getInteractive(false, API, callbackUrl, "Provide a valid callback URL, if required by the API:") [it]
		val String scope = httpServiceConfiguration.getInteractive(false, API, scope, "Provide a scope string, if required by the API:") [it]
		val SignatureType signatureType = httpServiceConfiguration.getInteractive(false, API, "signatureType", "Provide a valid signature type [" + SignatureType.values.join("|") + "] if required by the API:") [
			val result = SignatureType.valueOf(it)
			if (result == null) {
				throw new IllegalArgumentException()
			}
			return result
		]
		
		val serviceBuilder = new ServiceBuilder().provider(apiClass)
			.apiKey(apiKey)
			.apiSecret(apiSecret)
		if (callbackURL != null) {
			serviceBuilder.callback(callbackUrl)
		} 
		if (scope != null) {
			serviceBuilder.scope(scope)
		}
		if (signatureType != null) {
			serviceBuilder.signatureType(signatureType)
		}
		
		httpService =  serviceBuilder.build
		
		var userToken = httpServiceConfiguration.get(USER, userToken) as String
		var userSecret = httpServiceConfiguration.get(USER, userSecret) as String
		if (userToken == null || userSecret == null) {
			if (httpServiceConfiguration instanceof InteractiveServiceConfiguration) {
				val requestToken = httpService.requestToken
				val authorizationUrl = httpService.getAuthorizationUrl(requestToken)
				val verifier = httpServiceConfiguration.aquireInteractively("Go to the following URL and approve your app:\n" + authorizationUrl) [it]
				accessToken = httpService.getAccessToken(requestToken, new Verifier(verifier))
				userToken = accessToken.token
				userSecret = accessToken.secret
				httpServiceConfiguration.set(USER, ServiceConfiguration::userToken, userToken)
				httpServiceConfiguration.set(USER, ServiceConfiguration::userSecret, userSecret)									
			} else {
				accessToken = null
				throw new IllegalArgumentException("Configuration does not contain any user credentials.")
			}
		} else {
			accessToken = new Token(userToken, userSecret)
		}
	}
	
	private def <S extends Serializable> S getInteractive(ServiceConfiguration configuration, boolean checkNull, ServiceConfigurationScope scope, String key, String message, (String)=>S converter) {
		if (configuration instanceof InteractiveServiceConfiguration) {
			return configuration.getInteractive(scope, key, message, converter)
		} else {
			val result = configuration.get(scope, key)
			if (result == null && checkNull) {
				throw new IllegalArgumentException("The given configuration does not contain a necessary key")
			}
			return result as S
		}		
	}
	
	
	override synchronousRestCall(XRawHttpRequest httpRequest) throws XRawHttpException {
		val scribeHttpRequest = httpRequest.toScribe
		httpService.signRequest(accessToken, scribeHttpRequest)
		val scribeHttpResponse = scribeHttpRequest.send
		return new ScribeHttpResponse(scribeHttpResponse)
	}
	
}