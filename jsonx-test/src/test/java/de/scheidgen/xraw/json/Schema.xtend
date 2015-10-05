package de.scheidgen.xraw.json

import java.util.List
import java.util.Map

@JSON class SimpleJSONTestObject {
	String simpleString
	List<String> simpleList
	Map<String, String> simpleMap
	
	SimpleJSONTestObject object
	List<SimpleJSONTestObject> objectList
	Map<String,SimpleJSONTestObject> objectMap
}