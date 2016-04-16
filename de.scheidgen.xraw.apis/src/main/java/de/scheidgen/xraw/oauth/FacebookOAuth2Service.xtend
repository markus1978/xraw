package de.scheidgen.xraw.oauth

import com.mashape.unirest.http.Unirest
import de.scheidgen.xraw.core.XRawHttpException
import de.scheidgen.xraw.core.XRawHttpMethod
import de.scheidgen.xraw.core.XRawHttpRequest
import de.scheidgen.xraw.core.XRawHttpResponse
import de.scheidgen.xraw.core.XRawHttpService
import de.scheidgen.xraw.http.UnirestHttpRequest
import de.scheidgen.xraw.http.UnirestHttpResponse
import de.scheidgen.xraw.script.InteractiveServiceConfiguration
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration
import de.scheidgen.xraw.script.XRawHttpServiceConfigurationScope
import de.scheidgen.xraw.util.AddConstructor
import org.json.JSONException

import static de.scheidgen.xraw.script.XRawHttpServiceConfigurationScope.*

/*
 * TODO expire dates of access tokens, getting a new token
 */
@AddConstructor
class FacebookOAuth2Service implements XRawHttpService {
	
	val userAuthUrl = "https://www.facebook.com/dialog/oauth"
	val userTokenRequestUrl = "https://graph.facebook.com/v2.3/oauth/access_token"
	
	val XRawHttpServiceConfiguration httpServiceConfiguration
	
	protected def createAuthorizationUrl(String apiKey, String callbackURL, String scope) {
		new StringBuilder()
			.append(userAuthUrl).append("?").append("&")		
  			.append("client_id").append("=").append(apiKey).append("&")
  			.append("redirect_uri").append("=").append(callbackURL).append("&")
  			.append("scope").append("=").append(scope.replaceAll(" ", "+")).append("&")
  			.append("response_type").append("=").append("code").append("&")
  			.append("state").append("=").append("state").toString
	}
	
	private def authenticate(XRawHttpRequest httpRequest) throws XRawHttpException {	
		val String apiKey = httpServiceConfiguration.getInteractive(true, API, XRawHttpServiceConfiguration::apiKey, "We need your API key:")
		val String apiSecret = httpServiceConfiguration.getInteractive(true, API, XRawHttpServiceConfiguration::apiSecret, "We need your API secret:")
		val String callbackURL = httpServiceConfiguration.getInteractive(false, API, XRawHttpServiceConfiguration::callbackUrl, "Provide a valid callback URL, if required by the API:")
		val String scope = httpServiceConfiguration.getInteractive(false, API, XRawHttpServiceConfiguration::scope, "Provide a scope string, if required by the API:")		
		
		var userToken = httpServiceConfiguration.get(USER, XRawHttpServiceConfiguration::userToken) as String
		
		if (userToken == null) {
			if (httpServiceConfiguration instanceof InteractiveServiceConfiguration) {
				val authorizationUrl = createAuthorizationUrl(apiKey, callbackURL, scope)
				val verifier = httpServiceConfiguration.aquireInteractively("Go to the following URL and approve your app:\n" + authorizationUrl)
				
				val tokenRequest = Unirest.get(userTokenRequestUrl)
													.header("accept", "application/json")
													.queryString("code", verifier)
													.queryString("client_id", apiKey)
													.queryString("client_secret", apiSecret)
													.queryString("redirect_uri", callbackURL)
				val authentication = tokenRequest.asJson
				if (authentication.status == 200) {
					try {
						userToken = authentication.body.object.getString("access_token")											
					} catch (JSONException e) {
						println(authentication.body.object.toString)
						throw new XRawHttpException("Unexpected response.", e)
					}
					
					httpServiceConfiguration.set(USER, XRawHttpServiceConfiguration::userToken, userToken)
				} else {
					throw new XRawHttpException("Token request returned " + authentication.status + ": " + authentication.statusText);
				}
			} else {
				throw new XRawHttpException("Cryptographic material is missing.");
			}
		} 
		
  		httpRequest.headers.put("Authorization", "OAuth " + userToken)
  		return httpRequest
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

	override asynchronousRestCall(XRawHttpRequest request, (XRawHttpResponse)=>void handler) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override createEmptyRequest(XRawHttpMethod method, String url) {
		return new UnirestHttpRequest(method, url)
	}
	
	override synchronousRestCall(XRawHttpRequest httpRequest) throws XRawHttpException {
		val unirestResponse = (authenticate(httpRequest) as UnirestHttpRequest).toUnirest.asString
		return new UnirestHttpResponse(unirestResponse)
	}
	
}