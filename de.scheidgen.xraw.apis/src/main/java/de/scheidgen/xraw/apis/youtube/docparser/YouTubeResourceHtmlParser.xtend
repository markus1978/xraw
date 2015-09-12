package de.scheidgen.xraw.apis.youtube.docparser

import java.net.URL
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.jsoup.Jsoup

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*
import java.io.File
import java.io.PrintWriter
import java.util.Map

class ResourceClass {
	val String name
	val List<ResourceProperty> properties
	
	new(String name, List<ResourceProperty> properties) {
		this.name = name
		this.properties = properties
		expand
	}
	
	def cleanName(String name) {
		var result = name		
		result = result.replace(".(key)", "")
		result = result.replace("[]", "")
		return result.toFirstUpper
	}

	def void expand() {
		// filter merge (key) properties
		val toRemove = newArrayList
		val keyProperties = properties.filter[(it.name.endsWith(".(key)") && !it.name.substring(0, it.name.length - 6).contains("."))]
		keyProperties.forEach[keyProperty|
			val noneKeyProperty = properties.findFirst[it.name + ".(key)" == keyProperty.name]
			if (noneKeyProperty != null) {
				toRemove.add(noneKeyProperty)
				keyProperty.docHtml = noneKeyProperty.docHtml + "<br/><br/>" + keyProperty.docHtml
				keyProperty.name = keyProperty.name.substring(0, keyProperty.name.lastIndexOf("."))
				keyProperty.type = "map"
			}			
		]
		properties.removeAll(toRemove)
		toRemove.clear
		
		val rootProperties = properties.filter[(it.name.endsWith(".(key)") && !it.name.substring(0, it.name.length - 6).contains(".")) || !it.name.contains(".")]
		
		for(rootProperty: rootProperties) {			
			val containedProperties = newArrayList
			containedProperties.addAll(properties.filter[it.name.startsWith(rootProperty.name + ".")])
			if (!containedProperties.empty) {
				containedProperties.forEach[
					it.name = it.name.substring(rootProperty.name.length+1)
					if (it.name.startsWith("(key).")) {
						it.name = it.name.substring(6)
					}
				]
				toRemove.addAll(containedProperties)
				
				val subClass = new ResourceClass(name + rootProperty.name.cleanName, containedProperties)
				subClass.expand
				if (rootProperty.type == "map") {
					rootProperty.type = '''Map<String, «subClass.name»>'''
				} else {
					rootProperty.type = subClass.name					
				}

				rootProperty.objectType = subClass
			}
			
			if (rootProperty.name.endsWith("[]")) {
				var annotation = ""
				if (rootProperty.type == "list") {
					rootProperty.type = "String"
				}
				rootProperty.type = '''«annotation»List<«rootProperty.type»>'''
				rootProperty.name = rootProperty.name.replace("[]", "")
			}
		}
		properties.removeAll(toRemove)
	}

	public def allClasses() {
		return newArrayList(this).union(
			properties.filter[it.objectType != null].closure[if (it.objectType != null) objectType.properties.filter[it.objectType != null] else newArrayList].map[objectType]
		)
	}
	
	def generate(String superType) {
		'''
			@Resource
			class «name»«IF superType!=null» extends «superType»«ENDIF» {
				«FOR property: properties»
					/**
					 * «property.docHtml»
					 */
					«property.type» «property.name»
					
				«ENDFOR»
			}
		'''.toString
	}
	
}

class ResourceProperty {
	@Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var String name
	@Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var String type
	@Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var String docHtml
	
	@Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var ResourceClass objectType
	
	new(String name, String type, String docHtml) {
		this.name = name
		this.type = type
		this.docHtml = docHtml
	}
	
}

class YouTubeResourceHtmlParser {
	
	@Accessors(PUBLIC_GETTER) val Map<String, String> objectTypeProperties = newHashMap
	
	public static def resourceClassName(String resourceURL) {
		return "YouTube" + resourceURL.substring(resourceURL.lastIndexOf("/") + 1).toFirstUpper
	}

	def typeNameConversion(String htmlName) {
		if (htmlName == "string") {
			return "String"
		} else if (htmlName == "unsigned integer") {
			return "int"
		} else if (htmlName == "integer") {
			return "int"
		} else if (htmlName == "unsigned long") {
			return "long"
		} else if (htmlName == "long") {
			return "long"
		} else if (htmlName == "datetime") {
			return "@WithConverter(YouTubeDateConverter) Date"
		} else {
			return htmlName
		}
	}
	
	def parse(String resourceURL, String givenClassName) {
		val document = Jsoup::parse(new URL(resourceURL), 1000)
		val table = document.getElementById("property-table")
		val rawProperties = newArrayList
		for (tds: table.getElementsByTag("tr").filter[getElementsByTag("td").size == 2].map[getElementsByTag("td")]) {
			val name = tds.get(0).getElementsByTag("code").get(0).text.trim
			val type = tds.get(1).getElementsByTag("code").get(0).text.trim.typeNameConversion
			val doc = tds.get(1).html
			val cleanDoc = doc.substring(doc.indexOf("<br>")+5).trim
			
			if (name != "kind" && name != "etag") {
				val resolvedType = if (objectTypeProperties.get(name)!=null) {
					objectTypeProperties.get(name)
				} else {
					type
				}
				
				rawProperties.add(new ResourceProperty(name, resolvedType, cleanDoc))
			}
		}
		
		val className = if (givenClassName == null) resourceURL.resourceClassName else givenClassName
		val class = new ResourceClass(className, rawProperties)
		
		val file = new File("src/main/java/de/scheidgen/xraw/apis/youtube/resources/" + className + ".xtend")
		val out = new PrintWriter(file)
		out.println('''
			package de.scheidgen.xraw.apis.youtube.resources
			
			«FOR aClass: class.allClasses»
				«aClass.generate(if (aClass == class.allClasses.first) "AbstractYouTubeResource" else null)»
				
			«ENDFOR»
		''')
		out.close
	}

	public static def void main(String[] args) {
		val parser = new YouTubeResourceHtmlParser()
		parser.parse("https://developers.google.com/youtube/v3/docs/videos", null) 
	}	
}