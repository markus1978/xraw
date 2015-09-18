package de.scheidgen.xraw.apis.twitch

import de.scheidgen.xraw.annotations.Request
import de.scheidgen.xraw.annotations.Response
import de.scheidgen.xraw.annotations.UrlReplace

@Request(url="https://api.twitch.tv/kraken/videos/{id}", response=@Response(resourceType=TwitchVideo))
class Video {
	@UrlReplace("{id}") String id
}