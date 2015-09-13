package de.scheidgen.xraw.apis.youtube

import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.apis.google.GoogleOAuth2Service
import de.scheidgen.xraw.apis.youtube.search.List
import de.scheidgen.xraw.json.Converter
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration
import java.text.SimpleDateFormat
import java.util.Date

@Directory
@Service
class YouTube {
	Search search
	Channels channels
	Videos videos
	
	override protected createService(XRawHttpServiceConfiguration httpServiceConfig) {
		return new GoogleOAuth2Service(httpServiceConfig)
	}
}

@Directory
class Search {
	List list
}

@Directory
class Channels {
	de.scheidgen.xraw.apis.youtube.channels.List list
}

@Directory
class Videos {
	de.scheidgen.xraw.apis.youtube.videos.List list
}

class YouTubeDateConverter implements Converter<Date> {

	override toValue(String value) {
		return new SimpleDateFormat("YYYY-MM-DDThh:mm:ss.sZ").parse(value);
	}
	
	override toString(Date value) {
		return new SimpleDateFormat("YYYY-MM-DDThh:mm:ss.sZ").format(value);
	}

}