package de.scheidgen.xraw.apis.twitter.account

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.apis.twitter.response.TwitterUser
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.apis.twitter.TwitterResponse

@Request(url="https://api.twitter.com/1.1/account/verify_credentials.json", response=@Response(responseType=TwitterResponse, resourceType=TwitterUser))
class VerifyCredentials {
	/**
	 * The entities node will not be included when set to false.	
	 */
	boolean includeEntities

	/** 
	 * When set to either true, t or 1 statuses will not be included in the returned user object.
	 */
	boolean skipStatus

	/**
	 * Use of this parameter requires whitelisting. When set to true email will be returned in 
	 * the user objects as a string. If the user does not have an email address on their account, 
	 * or if the email address is un-verified, null will be returned.
	 */
	boolean includeEmail
}
