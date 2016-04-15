package de.scheidgen.xraw.json

import com.google.gwt.json.client.JSONBoolean
import com.google.gwt.json.client.JSONNumber
import com.google.gwt.json.client.JSONParser
import com.google.gwt.json.client.JSONString
import de.scheidgen.xraw.util.AddConstructor
import java.util.Collection

@AddConstructor
class JSONObject {
	
	public val com.google.gwt.json.client.JSONObject jsonObject
	
	new() {
		jsonObject = new com.google.gwt.json.client.JSONObject
	}
	
	new(String json) {
		jsonObject = JSONParser.parseLenient(json).isObject
	}
	
	def boolean isNull(String key) {
		return jsonObject.get(key) == null
	}
	
	def Object get(String key) {
		jsonObject.get(key)
	}
	
	def JSONObject getJSONObject(String key) {
		new JSONObject(jsonObject.get(key).object)	
	}
	
	def JSONArray getJSONArray(String key) {
		new JSONArray(jsonObject.get(key).array)
	}
	
	def String getString(String key) {
		jsonObject.get(key).string.stringValue
	}
	
	def boolean getBoolean(String key) {
		jsonObject.get(key).boolean.booleanValue
	}
	
	def int getInt(String key) {
		jsonObject.get(key).number.doubleValue as int
	}
	
	def long getLong(String key) {
		jsonObject.get(key).number.doubleValue as long
	}
	
	def double getDouble(String key) {
		jsonObject.get(key).number.doubleValue as int
	}
	
	def void put(String key, JSONArray value) {
		jsonObject.put(key, value.jsonArray)
	}
	
	def void put(String key, JSONObject value) {
		jsonObject.put(key, value.jsonObject)
	}
	
	def void put(String key, String value) {
		jsonObject.put(key, new JSONString(value))
	}
	
	def void put(String key, int value) {
		jsonObject.put(key, new JSONNumber(value))
	}
	
	def void put(String key, long value) {
		jsonObject.put(key, new JSONNumber(value))
	}
	
	def void put(String key, boolean value) {
		jsonObject.put(key, JSONBoolean.getInstance(value))
	}
	
	def void put(String key, double value) {
		jsonObject.put(key, new JSONNumber(value))
	}
	
	def void putOnce(String key, Object value) {
		if (jsonObject.get(key) == null) {
			switch value {
				JSONObject: put(key, value)
				JSONArray: put(key, value)
				Boolean: put(key, value)
				String: put(key, value)
				Integer: put(key, value)
				Long: put(key, value)
				Double: put(key, value)
				default: throw new IllegalArgumentException()
			}
		}
	}
	
	def Collection<String> keySet() {
		jsonObject.keySet
	}
	
	def int length() {
		jsonObject.size
	}
	
	def Object remove(String key) {
		throw new IllegalAccessException()
	}
	
	def String toString(int indent) {
		jsonObject.toString
	}
}

@AddConstructor
class JSONArray {
	public val com.google.gwt.json.client.JSONArray jsonArray
	
	new() {
		jsonArray = new com.google.gwt.json.client.JSONArray
	}
	
	new(String json) {
		jsonArray = JSONParser.parseLenient(json).array
	}
	
	def boolean isNull(int key) {
		return jsonArray.get(key) == null
	}
	
	def Object get(int key) {
		jsonArray.get(key)
	}
	
	def JSONObject getJSONObject(int key) {
		new JSONObject(jsonArray.get(key).object)	
	}
	
	def JSONArray getJSONArray(int key) {
		new JSONArray(jsonArray.get(key).array)
	}
	
	def String getString(int key) {
		jsonArray.get(key).string.stringValue
	}
	
	def boolean getBoolean(int key) {
		jsonArray.get(key).boolean.booleanValue
	}
	
	def int getInt(int key) {
		jsonArray.get(key).number.doubleValue as int
	}
	
	def long getLong(int key) {
		jsonArray.get(key).number.doubleValue as long
	}
	
	def double getDouble(int key) {
		jsonArray.get(key).number.doubleValue as int
	}
	
	def void put(int key, JSONArray value) {
		jsonArray.set(key, value.jsonArray)
	}
	
	def void put(int key, JSONObject value) {
		jsonArray.set(key, value.jsonObject)
	}
	
	def void put(int key, String value) {
		jsonArray.set(key, new JSONString(value))
	}
	
	def void put(int key, int value) {
		jsonArray.set(key, new JSONNumber(value))
	}
	
	def void put(int key, long value) {
		jsonArray.set(key, new JSONNumber(value))
	}
	
	def void put(int key, boolean value) {
		jsonArray.set(key, JSONBoolean.getInstance(value))
	}
	
	def void put(int key, double value) {
		jsonArray.set(key, new JSONNumber(value))
	}
	
	def void putOnce(int key, Object value) {
		if (jsonArray.get(key) == null) {
			switch value {
				JSONObject: put(key, value)
				JSONArray: put(key, value)
				Boolean: put(key, value)
				String: put(key, value)
				Integer: put(key, value)
				Long: put(key, value)
				Double: put(key, value)
				default: throw new IllegalArgumentException()
			}
		}
	}
	
	def int length() {
		jsonArray.size
	}
	
	def Object remove(int key) {
		throw new IllegalAccessException()
	}
	
	def String toString(int indent) {
		jsonArray.toString
	}
}