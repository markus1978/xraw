package de.scheidgen.xraw.json

import com.google.gwt.json.client.JSONBoolean
import com.google.gwt.json.client.JSONNumber
import com.google.gwt.json.client.JSONParser
import com.google.gwt.json.client.JSONString
import de.scheidgen.xraw.annotations.AddConstructor
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import jsinterop.annotations.JsMethod

@AddConstructor
@EqualsHashCode
class GwtJsonObject implements JSONObject {
	
	public val com.google.gwt.json.client.JSONObject jsonObject
	
	new() {
		jsonObject = new com.google.gwt.json.client.JSONObject
	}
	
	new(String json) {
		jsonObject = JSONParser.parseLenient(json).isObject
	}
	
	override isNull(String key) {
		return jsonObject.get(key) == null
	}
	
	override get(String key) {
		jsonObject.get(key)
	}
	
	override getJSONObject(String key) {
		new GwtJsonObject(jsonObject.get(key).object)	
	}
	
	override getJSONArray(String key) {
		new GwtJsonArray(jsonObject.get(key).array)
	}
	
	override getString(String key) {
		jsonObject.get(key)?.string?.stringValue
	}
	
	override getBoolean(String key) {
		jsonObject.get(key).boolean.booleanValue
	}
	
	override getInt(String key) {
		jsonObject.get(key).number.doubleValue as int
	}
	
	override getLong(String key) {
		jsonObject.get(key).number.doubleValue as long
	}
	
	override getDouble(String key) {
		jsonObject.get(key).number.doubleValue as int
	}
	
	override put(String key, JSONArray value) {
		jsonObject.put(key, (value as GwtJsonArray).jsonArray)
	}
	
	override put(String key, JSONObject value) {
		jsonObject.put(key, (value as GwtJsonObject).jsonObject)
	}
	
	override put(String key, String value) {
		if (value == null) {
			jsonObject.put(key, null)
		} else {
			jsonObject.put(key, new JSONString(value))			
		}
	}
	
	override put(String key, int value) {
		jsonObject.put(key, new JSONNumber(value))
	}
	
	override put(String key, long value) {
		jsonObject.put(key, new JSONNumber(value))
	}
	
	override put(String key, boolean value) {
		jsonObject.put(key, JSONBoolean.getInstance(value))
	}
	
	override put(String key, double value) {
		jsonObject.put(key, new JSONNumber(value))
	}
	
	override putOnce(String key, Object value) {
		if (jsonObject.get(key) == null) {
			switch value {
				JSONObject: put(key, value)
				JSONArray: put(key, value)
				Boolean: put(key, value)
				String: put(key, value)
				Integer: put(key, value)
				Long: put(key, value)
				Double: put(key, value)
				default: throw new UnsupportedOperationException
			}
		}
	}
	
	override keySet() {
		jsonObject.keySet
	}
	
	override length() {
		jsonObject.size
	}
	
	override remove(String key) {
		throw new UnsupportedOperationException
	}
	
	override toString(int indent) {
		jsonObject.toString
	}
	
	override xCreateNewArray() {
		new GwtJsonArray
	}
	
	override xCreateNewObject() {
		new GwtJsonObject
	}
	
	override xNative() {
		return jsonObject;
	}
	
	override xCopy() {
		return new GwtJsonObject(jsonObject.toString)
	}
	
	@JsMethod
	override xJavaScript() {
		NativeJavascriptUtils.unwrap(jsonObject)
	}	
}

@AddConstructor
class GwtJsonArray implements JSONArray {
	public val com.google.gwt.json.client.JSONArray jsonArray
	
	new() {
		jsonArray = new com.google.gwt.json.client.JSONArray
	}
	
	new(String json) {
		jsonArray = JSONParser.parseLenient(json).array
	}
	
	override isNull(int key) {
		return jsonArray.get(key) == null
	}
	
	override get(int key) {
		jsonArray.get(key)
	}
	
	override getJSONObject(int key) {
		new GwtJsonObject(jsonArray.get(key).object)	
	}
	
	override getJSONArray(int key) {
		new GwtJsonArray(jsonArray.get(key).array)
	}
	
	override getString(int key) {
		jsonArray.get(key).string.stringValue
	}
	
	override getBoolean(int key) {
		jsonArray.get(key).boolean.booleanValue
	}
	
	override getInt(int key) {
		jsonArray.get(key).number.doubleValue as int
	}
	
	override getLong(int key) {
		jsonArray.get(key).number.doubleValue as long
	}
	
	override getDouble(int key) {
		jsonArray.get(key).number.doubleValue as int
	}
	
	override put(int key, JSONArray value) {
		jsonArray.set(key, (value as GwtJsonArray).jsonArray)
	}
	
	override put(int key, JSONObject value) {
		jsonArray.set(key, (value as GwtJsonObject).jsonObject)
	}
	
	override put(int key, String value) {
		jsonArray.set(key, new JSONString(value))
	}
	
	override put(int key, int value) {
		jsonArray.set(key, new JSONNumber(value))
	}
	
	override put(int key, long value) {
		jsonArray.set(key, new JSONNumber(value))
	}
	
	override put(int key, boolean value) {
		jsonArray.set(key, JSONBoolean.getInstance(value))
	}
	
	override put(int key, double value) {
		jsonArray.set(key, new JSONNumber(value))
	}
	
	override putOnce(int key, Object value) {
		if (jsonArray.get(key) == null) {
			switch value {
				JSONObject: put(key, value)
				JSONArray: put(key, value)
				Boolean: put(key, value)
				String: put(key, value)
				Integer: put(key, value)
				Long: put(key, value)
				Double: put(key, value)
				default: throw new UnsupportedOperationException
			}
		}
	}
	
	override length() {
		jsonArray.size
	}
	
	override remove(int key) {
		throw new UnsupportedOperationException
	}
	
	override toString(int indent) {
		jsonArray.toString
	}
	
	override xCreateNewArray() {
		new GwtJsonArray
	}
	
	override xCreateNewObject() {
		new GwtJsonObject
	}
	
	override xNative() {
		return jsonArray
	}
	
}