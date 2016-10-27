package de.scheidgen.xraw.apis.twitter.direct_messages

import com.mashape.unirest.http.HttpMethod
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.TestMockupRequest
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterDirectMessage

/**
 * Sends a new direct message to the specified user from the authenticating user. Requires both the user and text parameters and must be a POST. Returns the sent message in the requested format if successful.
 * 
 * <h2>Direct Message Behavior</h2>
 * <p>The standard behavior of Direct Messages on Twitter requires that the recipient be following the sender. In most cases, any Direct Message sent to a recipient that is not following the sender will not be delivered and an error message will be returned.</p>
 * <p>Alternatively, a recipient may have their allow_dms_from account setting set to “all.” In this case, any Direct Message sent to the recipient will be delivered, regardless of whether the recipient follows the sender.</p>
 * <p>Once a Direct Message thread is established between two users, that thread can be used to send messages bi-directionally, regardless of the follow relationship. To discontinue the thread (effectively, leave the conversation), it is necessary to either explicitly leave the conversation in the Twitter client/website or perform a block of the user via the APIs or Twitter client/website.</p>
 */
@Request(url="https://api.twitter.com/1.1/direct_messages/destroy.json", method=HttpMethod.POST, response=@Response(resourceType=TwitterDirectMessage, responseType=TwitterResponse))
@TestMockupRequest
class Destroy {
	/**
	 * The ID of the direct message to delete.
	 */
	String id
}