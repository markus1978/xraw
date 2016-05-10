package de.scheidgen.xraw.server

import de.scheidgen.xraw.annotations.AddConstructor
import de.scheidgen.xraw.json.JSONArray
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.json.JSONObject

@AddConstructor
@EqualsHashCode
class JsonOrgObject implements de.scheidgen.xraw.json.JSONObject {
	
	public val JSONObject jsonObject
	
	new() {
		jsonObject = new JSONObject
	}
	
	new(String json) {
		jsonObject = new JSONObject(json)
	}
	
	override isNull(String key) {
		return jsonObject.isNull(key)
	}
	
	override get(String key) {
		jsonObject.get(key)
	}
	
	override getJSONObject(String key) {
		new JsonOrgObject(jsonObject.getJSONObject(key))	
	}
	
	override getJSONArray(String key) {
		new JsonOrgArray(jsonObject.getJSONArray(key))
	}
	
	override getString(String key) {
		jsonObject.getString(key)
	}
	
	override getBoolean(String key) {
		jsonObject.getBoolean(key)
	}
	
	override getInt(String key) {
		jsonObject.getInt(key)
	}
	
	override getLong(String key) {
		jsonObject.getLong(key)
	}
	
	override getDouble(String key) {
		jsonObject.getDouble(key)
	}
	
	override put(String key, JSONArray value) {
		jsonObject.put(key, (value as JsonOrgArray).jsonArray)
	}
	
	override put(String key, de.scheidgen.xraw.json.JSONObject value) {
		jsonObject.put(key, (value as JsonOrgObject).jsonObject)
	}
	
	override put(String key, String value) {
		jsonObject.put(key, value)
	}
	
	override put(String key, int value) {
		jsonObject.put(key, value)
	}
	
	override put(String key, long value) {
		jsonObject.put(key, value)
	}
	
	override put(String key, boolean value) {
		jsonObject.put(key, value)
	}
	
	override put(String key, double value) {
		jsonObject.put(key, value)
	}
	
	override putOnce(String key, Object value) {
		jsonObject.putOnce(key, value)		
	}
	
	override keySet() {
		jsonObject.keySet
	}
	
	override length() {
		jsonObject.length
	}
	
	override remove(String key) {
		jsonObject.remove(key)
	}
	
	override toString(int indent) {
		jsonObject.toString(indent)
	}
	
	override xCreateNewArray() {
		new JsonOrgArray
	}
	
	override xCreateNewObject() {
		new JsonOrgObject
	}
	
	override toString() {
		jsonObject.toString(4)
	}
	
}

@AddConstructor
class JsonOrgArray implements JSONArray {
	public val org.json.JSONArray jsonArray
	
	new() {
		jsonArray = new org.json.JSONArray
	}
	
	new(String json) {
		jsonArray = new org.json.JSONArray(json)
	}
	
	override isNull(int key) {
		jsonArray.isNull(key)
	}
	
	override get(int key) {
		jsonArray.get(key)
	}
	
	override getJSONObject(int key) {
		new JsonOrgObject(jsonArray.getJSONObject(key))	
	}
	
	override getJSONArray(int key) {
		new JsonOrgArray(jsonArray.getJSONArray(key))
	}
	
	override getString(int key) {
		jsonArray.getString(key)
	}
	
	override getBoolean(int key) {
		jsonArray.getBoolean(key)
	}
	
	override getInt(int key) {
		jsonArray.getInt(key)
	}
	
	override getLong(int key) {
		jsonArray.getLong(key)
	}
	
	override getDouble(int key) {
		jsonArray.getDouble(key)
	}
	
	override put(int key, JSONArray value) {
		jsonArray.put(key, (value as JsonOrgArray).jsonArray)
	}
	
	override put(int key, de.scheidgen.xraw.json.JSONObject value) {
		jsonArray.put(key, (value as JsonOrgObject).jsonObject)
	}
	
	override put(int key, String value) {
		jsonArray.put(key, value)
	}
	
	override put(int key, int value) {
		jsonArray.put(key, value)
	}
	
	override put(int key, long value) {
		jsonArray.put(key, value)
	}
	
	override put(int key, boolean value) {
		jsonArray.put(key, value)
	}
	
	override put(int key, double value) {
		jsonArray.put(key, value)
	}
	
	override putOnce(int key, Object value) {
		throw new IllegalAccessException()		
	}
	
	override length() {
		jsonArray.length
	}
	
	override remove(int key) {
		jsonArray.remove(key)
	}
	
	override toString(int indent) {
		jsonArray.toString(indent)
	}
	
	override xCreateNewArray() {
		new JsonOrgArray
	}
	
	override xCreateNewObject() {
		new JsonOrgObject
	}
	
	override toString() {
		jsonArray.toString(4)
	}
}