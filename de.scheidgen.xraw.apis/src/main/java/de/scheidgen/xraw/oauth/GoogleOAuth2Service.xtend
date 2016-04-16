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
import java.util.Date
import org.json.JSONException

import static de.scheidgen.xraw.script.XRawHttpServiceConfigurationScope.*

@AddConstructor
class GoogleOAuth2Service implements XRawHttpService {
	
	val userAuthUrl = "https://accounts.google.com/o/oauth2/auth"
	val userTokenRequestUrl = "https://accounts.google.com/o/oauth2/token"
	
	val XRawHttpServiceConfiguration httpServiceConfiguration
	
	protected def createAuthorizationUrl(String apiKey, String callbackURL, String scope) {
		new StringBuilder()
			.append(userAuthUrl).append("?").append("&")		
  			.append("client_id").append("=").append(apiKey).append("&")
  			.append("redirect_uri").append("=").append(callbackURL).append("&")
  			.append("scope").append("=").append(scope).append("&")
  			.append("response_type").append("=").append("code").append("&")
  			.append("access_type").append("=").append("offline").toString
	}
	
	private def authenticate(XRawHttpRequest httpRequest) throws XRawHttpException {	
		val String apiKey = httpServiceConfiguration.getInteractive(true, API, XRawHttpServiceConfiguration::apiKey, "We need your API key:")
		val String apiSecret = httpServiceConfiguration.getInteractive(true, API, XRawHttpServiceConfiguration::apiSecret, "We need your API secret:")
		val String callbackURL = httpServiceConfiguration.getInteractive(false, API, XRawHttpServiceConfiguration::callbackUrl, "Provide a valid callback URL, if required by the API:")
		val String scope = httpServiceConfiguration.getInteractive(false, API, XRawHttpServiceConfiguration::scope, "Provide a scope string, if required by the API:")		
		
		var userToken = httpServiceConfiguration.get(USER, XRawHttpServiceConfiguration::userToken) as String
		var userRefreshToken = httpServiceConfiguration.get(USER, "refreshToken") as String
		var userTokenExpireTimeStr = httpServiceConfiguration.get(USER, "userTokenExpireTime") as String
		var userTokenType = httpServiceConfiguration.get(USER, "userTokenType") as String
		
		if (userToken == null) {
			if (httpServiceConfiguration instanceof InteractiveServiceConfiguration) {
				/*
				 * https://accounts.google.com/o/oauth2/auth?
		  		 * client_id=1084945748469-eg34imk572gdhu83gj5p0an9fut6urp5.apps.googleusercontent.com&
		  		 * redirect_uri=http%3A%2F%2Flocalhost%2Foauth2callback&
		  		 * scope=https://www.googleapis.com/auth/youtube&
		  		 * response_type=code&
		  		 * access_type=offline
				 */
				val authorizationUrl = createAuthorizationUrl(apiKey, callbackURL, scope)
				val verifier = httpServiceConfiguration.aquireInteractively("Go to the following URL and approve your app:\n" + authorizationUrl)
				
				val tokenRequest = Unirest.post(userTokenRequestUrl)
													.header("Content-Type", "application/x-www-form-urlencoded")
													.header("accept", "application/json")
													.field("code", verifier)
													.field("client_id", apiKey)
													.field("client_secret", apiSecret)
													.field("redirect_uri", callbackURL)
													.field("grant_type", "authorization_code")
				val authentication = tokenRequest.asJson
				if (authentication.status == 200) {
					try {
						userToken = authentication.body.object.getString("access_token")
						userRefreshToken = authentication.body.object.getString("refresh_token")
						userTokenType = authentication.body.object.getString("token_type")
						val expiresIn = authentication.body.object.getLong("expires_in")
						userTokenExpireTimeStr = Long.toString(new Date().time + expiresIn*1000)						
					} catch (JSONException e) {
						println(authentication.body.object.toString)
						throw new XRawHttpException("Unexpected response.", e)
					}
					
					httpServiceConfiguration.set(USER, XRawHttpServiceConfiguration::userToken, userToken)
					httpServiceConfiguration.set(USER, "refreshToken", userRefreshToken)
					httpServiceConfiguration.set(USER, "userTokenExpireTime", userTokenExpireTimeStr) 
					httpServiceConfiguration.set(USER, "userTokenType", userTokenType)
				} else {
					throw new XRawHttpException("Token request returned " + authentication.status + ": " + authentication.statusText);
				}
			} else {
				throw new XRawHttpException("Cryptographic material is missing.");
			}
		} else {
			val date = new Date().time
			val userTokenExpireTime = Long.parseLong(userTokenExpireTimeStr)
			if (date > userTokenExpireTime - 10000) {
				// refresh the access token
				val authentication = Unirest.post(userTokenRequestUrl)
									.header("Content-Type", "application/x-www-form-urlencoded")
									.header("accept", "application/json")
									.field("client_id", apiKey)
									.field("client_secret", apiSecret)
									.field("refresh_token", userRefreshToken)
									.field("grant_type", "refresh_token").asJson
				if (authentication.status == 200) {
					userToken = authentication.body.object.getString("access_token")
					userTokenType = authentication.body.object.getString("token_type")
					val expiresIn = authentication.body.object.getLong("expires_in")
					userTokenExpireTimeStr = Long.toString(new Date().time + expiresIn*1000)
					
					httpServiceConfiguration.set(USER, XRawHttpServiceConfiguration::userToken, userToken)
					httpServiceConfiguration.set(USER, "userTokenExpireTime", userTokenExpireTimeStr) 
					httpServiceConfiguration.set(USER, "userTokenType", userTokenType)					
				} else {
					throw new XRawHttpException("Refresh token request returned " + authentication.status);
				}
			}
		}
		
  		httpRequest.headers.put("Authorization", userTokenType + " " + userToken)
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