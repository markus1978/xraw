package de.scheidgen.xraw.json

import org.junit.Assert
import org.junit.Test
import de.scheidgen.xraw.server.JsonOrgObject

class JSONObjectTests {
	
	@Test def void SimpleStringAccessTest() {
		val json = '''
			{
				simpleString: "Hello"
			}
		'''
		val object = new SimpleJSONTestObject(new JsonOrgObject(json))
		
		Assert.assertEquals("Hello", object.simpleString)
	}
	
	@Test def void SimpleListAccessTest() {
		val json = '''
			{
				simpleList: ["one","two"]
			}
		'''
		val object = new SimpleJSONTestObject(new JsonOrgObject(json))
		
		Assert.assertEquals("two", object.simpleList.get(1))
	}
	
	@Test def void SimpleMapAccessTest() {
		val json = '''
			{
				simpleMap: {
					"one" : "this is 1",
					"two" : "this is 2"
				}
			}
		'''
		val object = new SimpleJSONTestObject(new JsonOrgObject(json))
		
		Assert.assertEquals("this is 2", object.simpleMap.get("two"))
	}
	
		@Test def void SimpleStringModifyTest() {
		val json = '''
			{
				simpleString: "Hello"
			}
		'''
		val object = new SimpleJSONTestObject(new JsonOrgObject(json))
		object.simpleString = "modified"
		
		Assert.assertEquals("modified", object.simpleString)
	}
	
	@Test def void SimpleListModifyTest() {
		val json = '''
			{
				simpleList: ["one","two"]
			}
		'''
		val object = new SimpleJSONTestObject(new JsonOrgObject(json))
		object.simpleList.set(1, "TWO")
		
		Assert.assertEquals("TWO", object.simpleList.get(1))
	}
	
	@Test def void SimpleListAddTest() {
		val json = '''
			{
				simpleList: ["one","two"]
			}
		'''
		val object = new SimpleJSONTestObject(new JsonOrgObject(json))
		object.simpleList.add("three")
		
		Assert.assertEquals("three", object.simpleList.get(2))
	}
	
	@Test def void SimpleMapModifyTest() {
		val json = '''
			{
				simpleMap: {
					"one" : "this is 1",
					"two" : "this is 2"
				}
			}
		'''
		val object = new SimpleJSONTestObject(new JsonOrgObject(json))
		object.simpleMap.put("two", "2")
		
		Assert.assertEquals("2", object.simpleMap.get("two"))
	}
	
	@Test def void SimpleMapAddTest() {
		val json = '''
			{
				simpleMap: {
					"one" : "this is 1",
					"two" : "this is 2"
				}
			}
		'''
		val object = new SimpleJSONTestObject(new JsonOrgObject(json))
		object.simpleMap.put("three", "3")
		
		Assert.assertEquals("3", object.simpleMap.get("three"))
	}
}