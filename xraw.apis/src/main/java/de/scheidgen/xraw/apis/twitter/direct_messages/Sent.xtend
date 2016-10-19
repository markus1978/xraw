package de.scheidgen.xraw.apis.twitter.direct_messages

import com.mashape.unirest.http.HttpMethod
import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.TestMockupRequest
import de.scheidgen.xraw.apis.twitter.TwitterResponse
import de.scheidgen.xraw.apis.twitter.response.TwitterDirectMessage

import static extension com.mashape.unirest.http.HttpMethod.*

/**
 * Returns the 20 most recent direct messages sent by the authenticating user. Includes detailed information about the sender and recipient user. You can request up to 200 direct messages per call, up to a maximum of 800 outgoing DMs. Important: This method requires an access token with RWD (read, write & direct message) permissions. Consult The Application Permission Model for more information.
 */
@Request(url="https://api.twitter.com/1.1/direct_messages/send.json", method=HttpMethod.GET, response=@Response(resourceType=TwitterDirectMessage, isList=true, responseType=TwitterResponse))
@TestMockupRequest
class Sent {

	/**
	 * Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available.
	 */
	String since_id
	
	/**
	 * Specifies the number of records to retrieve. Must be less than or equal to 200.
	 */
	int count

	/**
	 * Returns results with an ID less than (that is, older than) or equal to the specified ID.
	 */	
	String max_id

	/** 
	 * The entities node will not be included when set to false.
	 */
	boolean include_entities
	
	/**
	 * Specifies the page of results to retrieve. Example Values: 3
	 */
	int page
}
