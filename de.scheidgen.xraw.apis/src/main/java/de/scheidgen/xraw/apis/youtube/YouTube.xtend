package de.scheidgen.xraw.apis.youtube

import de.scheidgen.xraw.annotations.Converter
import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.apis.youtube.search.List
import java.text.SimpleDateFormat
import java.util.Date

@Directory
@Service(Google2Api)
class YouTube {
	Search search
	Channel channel
}

@Directory
class Search {
	List list
}

@Directory
class Channel {
	de.scheidgen.xraw.apis.youtube.channels.List list
}

class YouTubeDateConverter implements Converter<Date> {

	override convert(String value) {
		return new SimpleDateFormat("YYYY-MM-DDThh:mm:ss.sZ").parse(value);
	}

}