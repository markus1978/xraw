package de.scheidgen.xraw.server

import de.scheidgen.xraw.json.XObject
import java.io.PrintStream
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths
import java.util.Map
import java.io.FileOutputStream
import java.io.File
import java.util.regex.Pattern
import de.scheidgen.xraw.json.JSONObject

class XLogBasedStore {	
	val debug = true
	
	val PrintStream out
	val Map<String, XObject> data = newHashMap
	
	new(String path) {
		if (path == null) {
			out = System.out
		} else {
			val file = new File(path)
			if (file.exists) {
				val lines = Files.readAllLines(Paths.get(path), StandardCharsets.UTF_8)
				val reqexp = "^(CREATE|UPDATE|DELETE) ([^\\s_]+)(\\s|_)([^\\s]+) (.*)$"
				val pattern = Pattern.compile(reqexp)
				for(it:lines) {
					val matcher = pattern.matcher(it)
					if (!matcher.matches) {
						throw new RuntimeException("Wrong format!")
					} 
					val action = matcher.group(1)
					val type = matcher.group(2) 
					val objectId = matcher.group(4)
					val data = matcher.group(5)
					
					if (action == "DELETE") {
						this.data.remove(id(type, objectId))
					} else if (action == "CREATE" || action == "UPDATE") {
						val object = try {
							val class = Thread.currentThread.contextClassLoader.loadClass(type)
							val contructor = class.constructors.findFirst[parameterTypes.length == 1 && parameterTypes.get(0) == JSONObject]
							contructor.newInstance(new JsonOrgObject(data))	
						} catch (Throwable e) {
							throw new RuntimeException("Wrong format!", e)
						}						
						this.data.put(id(type, objectId), object as XObject)
					} else {
						throw new RuntimeException("Wrong format!")
					}
				}
			}
			
			out = new PrintStream(new FileOutputStream(file, true))
		}
	}
	
	private def String serialize(XObject object) {
		return object.xJson.toString(0).replaceAll("\\n", " ")
	}
	
	private def println(String str) {
		out.println(str)
		out.flush
		
		if (out != System.out && debug) {
			System.out.println(str)
		}
	}
	
	private def id(String typeId, String objectId) {
		(typeId?:"") + "_" + objectId
	}
	
	private def type(XObject object) {
		object.class.canonicalName
	}
	
	
	def XObject create(String objectId, XObject object) {
		val id = id(object.type, objectId) 
		if (data.get(id) != null) {
			throw new IllegalStateException("Id already exists.")
		}
		
		println('''CREATE «object.type» «objectId.trim» «object.serialize»''')
		return object
	}
	
	def XObject update(String objectId, XObject object) {
		val id = id(object.type, objectId)
		if (data.get(id) == null) {
			throw new IllegalStateException("Id does not already exists.")
		}
		
		println('''UPDATE «object.type» «objectId.trim» «object.serialize»''')
		return object
	}
	
	def XObject set(String objectId, XObject object) {
		val id = id(object.type, objectId)
		if (data.get(id) != null) {
			update(objectId, object)
		} else {
			create(objectId, object)
		}
	}
	
	def void delete(String objectId, XObject object) {	
		val id = id(object.type, objectId)
		if (data.get(id) == null) {
			throw new IllegalStateException("Id does not already exists.")
		}
		
		println('''DELETE «object.type» «objectId.trim»''')
	}
	
	def <T extends XObject> Iterable<T> getAll(Class<T> clazz) {
		data.entrySet.filter[key.startsWith(clazz.canonicalName + "_")].map[value as T].toList
	}
	
	def <T> T get(Class<? extends XObject> clazz, String objectId) {
		val id = id(clazz.canonicalName, objectId)
		return data.get(id) as T
	}
	
}