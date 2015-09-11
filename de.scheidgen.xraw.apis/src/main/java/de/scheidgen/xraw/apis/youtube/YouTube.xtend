package de.scheidgen.xraw.apis.youtube

import de.scheidgen.xraw.annotations.Converter
import de.scheidgen.xraw.annotations.Directory
import de.scheidgen.xraw.annotations.Service
import de.scheidgen.xraw.apis.youtube.search.List
import de.scheidgen.xraw.script.ServiceConfiguration
import java.text.SimpleDateFormat
import java.util.Date

@Directory
@Service
class YouTube {
	Search search
	
	override protected createService(ServiceConfiguration httpServiceConfig) {
		return null; //TODO
	}
}

@Directory
class Search {
	List list
}

class YouTubeDateConverter implements Converter<Date> {

	override convert(String value) {
		return new SimpleDateFormat("YYYY-MM-DDThh:mm:ss.sZ").parse(value);
	}

}