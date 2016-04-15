package de.scheidgen.xraw.http

import de.scheidgen.xraw.core.XRawHttpException
import de.scheidgen.xraw.core.XRawHttpMethod
import de.scheidgen.xraw.core.XRawHttpRequest
import de.scheidgen.xraw.core.XRawHttpResponse
import de.scheidgen.xraw.core.XRawHttpService
import de.scheidgen.xraw.script.InteractiveServiceConfiguration
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration
import de.scheidgen.xraw.script.XRawHttpServiceConfigurationScope
import de.scheidgen.xraw.util.AddConstructor
import org.scribe.builder.ServiceBuilder
import org.scribe.builder.api.Api
import org.scribe.model.Response
import org.scribe.model.SignatureType
import org.scribe.model.Token
import org.scribe.model.Verifier
import org.scribe.oauth.OAuthService

import static de.scheidgen.xraw.script.XRawHttpServiceConfiguration.*
import static de.scheidgen.xraw.script.XRawHttpServiceConfigurationScope.*

class ScribeOAuth1Service implements XRawHttpService {
	
	val OAuthService httpService
	val Token accessToken
	
	new(Class<? extends Api> apiClass, XRawHttpServiceConfiguration httpServiceConfiguration) {
		
		val String apiKey = httpServiceConfiguration.getInteractive(true, API, apiKey, "We need your API key:")
		val String apiSecret = httpServiceConfiguration.getInteractive(true, API, apiSecret, "We need your API secret:")
		val String callbackURL = httpServiceConfiguration.getInteractive(false, API, callbackUrl, "Provide a valid callback URL, if required by the API:")
		val String scope = httpServiceConfiguration.getInteractive(false, API, scope, "Provide a scope string, if required by the API:")
		val String signatureTypeStr = httpServiceConfiguration.getInteractive(false, API, "signatureType", "Provide a valid signature type [" + SignatureType.values.join("|") + "] if required by the API:")
		val SignatureType signatureType = if (signatureTypeStr == null || signatureTypeStr == "") {
			SignatureType.Header	
		} else {
			SignatureType.valueOf(signatureTypeStr)			
		}		
		
		val serviceBuilder = new ServiceBuilder().provider(apiClass)
			.apiKey(apiKey)
			.apiSecret(apiSecret)
		if (callbackURL != null && callbackURL != "") {
			serviceBuilder.callback(callbackUrl)
		} 
		if (scope != null && scope != "") {
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
				val verifier = httpServiceConfiguration.aquireInteractively("Go to the following URL and approve your app:\n" + authorizationUrl)
				accessToken = httpService.getAccessToken(requestToken, new Verifier(verifier))
				userToken = accessToken.token
				userSecret = accessToken.secret
				httpServiceConfiguration.set(USER, XRawHttpServiceConfiguration::userToken, userToken)
				httpServiceConfiguration.set(USER, XRawHttpServiceConfiguration::userSecret, userSecret)									
			} else {
				accessToken = null
				throw new IllegalArgumentException("Configuration does not contain any user credentials.")
			}
		} else {
			accessToken = new Token(userToken, userSecret)
		}
	}
	
	private def String getInteractive(XRawHttpServiceConfiguration configuration, boolean checkNull, XRawHttpServiceConfigurationScope scope, String key, String message) {
		if (configuration instanceof InteractiveServiceConfiguration) {
			return configuration.getInteractive(scope, key, message)
		} else {
			val result = configuration.get(scope, key)
			if (result == null && checkNull) {
				throw new IllegalArgumentException("The given configuration does not contain a necessary key")
			}
			return result
		}		
	}
	
	override createEmptyRequest(XRawHttpMethod method, String url) {
		return new UnirestHttpRequest(method, url)
	}
	
	override synchronousRestCall(XRawHttpRequest httpRequest) throws XRawHttpException {
		val scribeHttpRequest = (httpRequest as UnirestHttpRequest).toScribe
		httpService.signRequest(accessToken, scribeHttpRequest)
		val scribeHttpResponse = scribeHttpRequest.send
		return new ScribeHttpResponse(scribeHttpResponse)
	}	
}

@AddConstructor
class ScribeHttpResponse implements XRawHttpResponse {
	val Response source
	
	override getBody() {
		return source.body
	}
	
	override getHeaders() {
		return source.headers
	}
	
	override getStatus() {
		return source.code
	}
	
	override getStatusText() {
		return source.message
	}
}