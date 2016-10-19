package de.scheidgen.xraw.mongodb

import com.google.common.collect.AbstractIterator
import com.google.common.collect.FluentIterable
import com.mongodb.BasicDBObject
import com.mongodb.MongoClient
import com.mongodb.client.FindIterable
import com.mongodb.client.MongoCollection
import com.mongodb.client.MongoDatabase
import com.mongodb.client.model.IndexOptions
import de.scheidgen.xraw.server.XResource
import org.bson.Document
import org.json.JSONObject

class MongoDB {
	public static val client = new MongoClient	
	protected val MongoDatabase source
	
	new(String name) {
		source = client.getDatabase(name)
	}
}

class Collection<E extends XResource> {
	val MongoDB db
	val MongoCollection<Document> source
	val Class<E> clazz
	var String indexKey = null
	
	
	new(MongoDB db, String name, Class<E> clazz) {
		this.db = db
		this.source = db.source.getCollection(name)
		this.clazz = clazz
	}
	
	def withUUID(String key) {
		source.createIndex(new BasicDBObject(key, 1), new IndexOptions().unique(true))	
		this.indexKey = key
		return this
	}
	
	def withIndex(String key, int direction) {
		source.createIndex(new BasicDBObject(key, direction))
		return this
	}
	
	def add(E value) {
		value.xJson.putOnce("xClass", value.class.canonicalName)
		source.insertOne(Document::parse(value.xString))
	}
	
	def E get(String key) {
		val dbDocument = source.find(new BasicDBObject(indexKey, key)).first
		if (dbDocument == null) {
			return null
		}
		val json = new JSONObject(dbDocument.toJson)
		return clazz.getConstructor(JSONObject).newInstance(json) as E
	}
	
	private def E toJsonx(Document document) {
		val json = new JSONObject(document.toJson)
		val clazz = if (!json.isNull("xClass")) Thread::currentThread.contextClassLoader.loadClass(json.getString("xClass")) else this.clazz
		
		val result = clazz.getConstructor(JSONObject).newInstance(json) as E
		result.xSetSave[
			source.replaceOne(new BasicDBObject(indexKey, document.get(indexKey)), Document::parse(result.xString))
			return null
		]
		return result
	}
	
	def Iterable<E> query((MongoCollection<Document>)=>FindIterable<Document> query) {
		val result = query.apply(source).iterator
		return new FluentIterable<E>() {			
			override iterator() {
				return new AbstractIterator<E>() {					
					override protected computeNext() {
						if (result.hasNext) {
							val next = result.next
							return next.toJsonx
						} else {
							return endOfData
						}
					}					
				}
			}			
		}
	}
	
	def Iterable<E> find(BasicDBObject query, int limit) {
		val result = (if (query == null) 
			if (limit != -1) {
				source.find().limit(limit)
			} else {
				source.find()			
			}
		else
			if (limit != -1) {
				source.find(query).limit(limit)
			} else {
				source.find(query)			
			} 			
		).iterator
		return new FluentIterable<E>() {			
			override iterator() {
				return new AbstractIterator<E>() {					
					override protected computeNext() {
						if (result.hasNext) {
							val next = result.next
							return next.toJsonx
						} else {
							return endOfData
						}
					}					
				}
			}			
		}
	}
}
