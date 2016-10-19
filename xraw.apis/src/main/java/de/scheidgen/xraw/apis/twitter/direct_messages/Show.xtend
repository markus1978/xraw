package de.scheidgen.xraw.apis.twitter.direct_messages

import com.mashape.unirest.http.HttpMethod
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.TestMockupRequest
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterDirectMessage

/**
 * Returns a single direct message, specified by an id parameter. Like the /1.1/direct_messages.format request, this method will include the user objects of the sender and recipient. Important: This method requires an access token with RWD (read, write & direct message) permissions. Consult The Application Permission Model for more information.
 */
@Request(url="https://api.twitter.com/1.1/direct_messages/show.json", method=HttpMethod.GET, response=@Response(resourceType=TwitterDirectMessage, isList=true, responseType=TwitterResponse))
@TestMockupRequest
class Show {

	/**
	 * The ID of the direct message.
	 */
	String id
}
