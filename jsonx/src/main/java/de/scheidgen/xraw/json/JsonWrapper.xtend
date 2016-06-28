package de.scheidgen.xraw.json

import java.util.Collection
import com.google.gwt.core.client.JavaScriptObject

interface JSONObject {
		
	def boolean isNull(String key)
	
	def Object get(String key)
	
	def JSONObject getJSONObject(String key)
	
	def JSONArray getJSONArray(String key)
	
	def String getString(String key)
	
	def boolean getBoolean(String key)
	
	def int getInt(String key)
	
	def long getLong(String key) 
	
	def double getDouble(String key)
	
	def void put(String key, JSONArray value)
	
	def void put(String key, JSONObject value)
	
	def void put(String key, String value)
	
	def void put(String key, int value)
	
	def void put(String key, long value)
	
	def void put(String key, boolean value) 
	
	def void put(String key, double value)
	
	def void putOnce(String key, Object value)
	
	def Collection<String> keySet()
	
	def int length()
	
	def Object remove(String key)
	
	def String toString(int indent)
	
	def JSONObject xCreateNewObject()
	
	def JSONArray xCreateNewArray()
	
	def Object xNative()
	
	def JSONObject xCopy()
	
	def JavaScriptObject xJavaScript()
}

interface JSONArray {	
	
	def boolean isNull(int key)
	
	def Object get(int key) 
	
	def JSONObject getJSONObject(int key)
	
	def JSONArray getJSONArray(int key)
	
	def String getString(int key)
	
	def boolean getBoolean(int key)
	
	def int getInt(int key)
	
	def long getLong(int key) 
	
	def double getDouble(int key)
	
	def void put(int key, JSONArray value)
	
	def void put(int key, JSONObject value)
	
	def void put(int key, String value) 
	
	def void put(int key, int value) 
	
	def void put(int key, long value)
	
	def void put(int key, boolean value) 
	
	def void put(int key, double value) 
		
	def void putOnce(int key, Object value) 
	
	def int length()
	
	def Object remove(int key) 
	
	def String toString(int indent)
	
	def JSONObject xCreateNewObject()
	
	def JSONArray xCreateNewArray()
	
	def Object xNative()
}