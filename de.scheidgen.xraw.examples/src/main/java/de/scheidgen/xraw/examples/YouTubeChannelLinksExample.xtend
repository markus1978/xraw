package de.scheidgen.xraw.examples

import de.scheidgen.xraw.AbstractRequest
import de.scheidgen.xraw.DefaultResponse
import de.scheidgen.xraw.apis.youtube.YouTube
import de.scheidgen.xraw.script.XRawScript
import de.scheidgen.xraw.util.AddConstructor
import de.scheidgen.xraw.util.XRawIterateExtensions
import java.net.HttpURLConnection
import java.net.URL
import org.jsoup.Jsoup

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*

@AddConstructor
class YouTubeChannelLinksExample {
	
	private static def<R extends AbstractRequest<? extends DefaultResponse,?>> xCheck(R request) {
		if (!request.xResponse.successful) {
			println("Api error: " + request.xResponse.code)
			throw new RuntimeException("Abort")
		}
		return request
	}
	
	val YouTube youtube = XRawScript::get("data/store.json", "markus", YouTube)
	
	val String[] titles
	val String language 
	
	val concurrent = XRawIterateExtensions::concurrent
	
	def run() {
		concurrent.collect(titles) [title|
			val search = youtube.search.list.part("snippet").q(title).relevanceLanguage(language).type("channel").xCheck
			val channelList = youtube.channels.list.id(search.xResult.items.get(0).snippet.channelId).part("brandingSettings,statistics,status,snippet,contentDetails,contentOwnerDetails,id").xCheck
			val channel = channelList.xResult.items.get(0)
			
			val channelAbout = Jsoup::parse(new URL('''https://www.youtube.com/channel/«channel.id»/about'''), 1000)
			val rawLinks = channelAbout.getElementsByClass("about-custom-links").collectAll[
				it.getElementsByTag("a").collect[it.attr("href")]
			]
			val links = concurrent.collect(rawLinks)[link|
				var location = link
				try {
					var connection = new URL(location).openConnection() as HttpURLConnection
					connection.setInstanceFollowRedirects(false);
					while (connection.getResponseCode() / 100 == 3) {
						connection.connect
	    				location = connection.getHeaderField("location");
	    				connection.inputStream.close
	    				connection = new URL(location).openConnection() as HttpURLConnection
	    				connection.setInstanceFollowRedirects(false);
					}					
				} catch (Exception e) {
					return link
				}				
				
				return location
			]
			
			return '''
				«channel.brandingSettings.channel.title»:
				«FOR link: links»
					«link»
				«ENDFOR»
				
			'''.toString					
		].forEach[println(it)]
	}
		
	static def void main(String[] args) {		
		new YouTubeChannelLinksExample(#{"beartaffy", "markiplier", "pewdiepie", "quill18", "extracredits"}, "en").run
	}
}