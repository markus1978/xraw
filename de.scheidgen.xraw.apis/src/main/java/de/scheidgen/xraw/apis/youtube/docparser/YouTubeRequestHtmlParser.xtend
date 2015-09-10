package de.scheidgen.xraw.apis.youtube.docparser

import org.jsoup.Jsoup
import java.net.URL
import org.eclipse.xtend.lib.annotations.Accessors
import java.io.PrintWriter

class RequestProperty {
	@Accessors(PUBLIC_GETTER) val String name
	@Accessors(PUBLIC_GETTER) val String type
	@Accessors(PUBLIC_GETTER) val String docHtml
	
	new(String name, String type, String docHtml) {
		this.name = name
		this.type = type
		this.docHtml = docHtml
	}
	
}

class RequestHtmlParser {

	
	def typeNameConversion(String htmlName) {
		if (htmlName == "string") {
			return "String"
		} else if (htmlName == "unsigned integer") {
			return "int"
		} else if (htmlName == "integer") {
			return "int"
		} else if (htmlName == "datetime") {
			return "@WithConverter(YouTubeDateConverter) Date"
		} else {
			return htmlName
		}
	}
	
	def parse(String url) {
		val document = Jsoup::parse(new URL(url), 1000)
		val request = document.getElementById("request")
		val params = request.getElementById("params")
		val paramsTable = params.getElementsByTag("table").get(0)
		
		val properties = newArrayList
		val trs = paramsTable.getElementsByTag("tr")
		for (tr: trs) {
			val tds = tr.getElementsByTag("td")
			if (tds.size == 2) {
				val name = tds.get(0).getElementsByTag("code").get(0).text.trim
				val type = tds.get(1).getElementsByTag("code").get(0).text.trim.typeNameConversion
				val doc = tds.get(1).html
				val cleanDoc = doc.substring(doc.indexOf("<br>")+5).trim
				
				properties.add(new RequestProperty(name, type, cleanDoc))
			}
		}	

		val requestStr = request.getElementById("request_url").getElementsByTag("pre").get(0).text
		val method = requestStr.split(" ").get(0)
		val requestUrl = requestStr.split(" ").get(1)
		
		val sectionUrl = url.substring(0, url.lastIndexOf("/"))
		val packageStr = sectionUrl.substring(sectionUrl.lastIndexOf("/")+1).toLowerCase
		val package = "de.scheidgen.xraw.apis.youtube." + packageStr
		val className = url.substring(url.lastIndexOf("/")+1).toFirstUpper
		
		val resourceTypeStr = "YouTube" + packageStr.toFirstUpper + className + "Response"
		
		val fileStr = "src/main/java/" + package.replace(".", "/") + "/" + className + ".xtend"
		val out = new PrintWriter(fileStr)
		out.println('''
			package «package»
			
			@Request(url="«requestUrl»", «IF method!="GET"»method=Verb.«method», «ENDIF»response=@Response(resourceType=«resourceTypeStr»))
			class «className» {
				«FOR property: properties»
					/**
					 * «property.docHtml»
					 */
					«property.type» «property.name»
					
				«ENDFOR»
			}
		''')
		out.close
		
		val response = document.getElementById("response")
		var resourceUrl = response.getElementsByClass("resource-link").get(0).attr("href")
		resourceUrl = if (resourceUrl.contains("#")) resourceUrl.substring(0, resourceUrl.lastIndexOf("#")) else resourceUrl
		val resourceParser = new YouTubeResourceHtmlParser()
		resourceParser.objectTypeProperties.put("items[]", YouTubeResourceHtmlParser::resourceClassName(resourceUrl))
		resourceParser.parse(url, resourceTypeStr)
	}

	public static def void main(String[] args) {
		new RequestHtmlParser().parse("https://developers.google.com/youtube/v3/docs/channels/list")
	}	
}