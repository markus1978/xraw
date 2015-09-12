package de.scheidgen.xraw.script

import de.scheidgen.xraw.model.EStringToSerializableMapEntry
import de.scheidgen.xraw.model.Service
import de.scheidgen.xraw.model.ServiceCredentials
import de.scheidgen.xraw.model.XRawScriptModelFactory
import de.scheidgen.xraw.util.AddConstructor
import java.util.Scanner
import org.eclipse.emf.common.util.EList

enum XRawHttpServiceConfigurationScope {
	API, USER
}

interface XRawHttpServiceConfiguration {
	public static val apiKey = "apiKey"
	public static val apiSecret = "apiSecret"
	public static val userToken = "accessToken"
	public static val userSecret = "secret"
	public static val callbackUrl = "callbackUrl"
	public static val scope = "scope"
	
	def String get(XRawHttpServiceConfigurationScope scope, String key)
	def void set(XRawHttpServiceConfigurationScope scope, String key, String value)	
}

interface InteractiveServiceConfiguration extends XRawHttpServiceConfiguration {
	def  String aquireInteractively(String message)
	def  String getInteractive(XRawHttpServiceConfigurationScope scope, String key, String message)
}

abstract class AbstractInteractiveServiceConfiguration implements InteractiveServiceConfiguration {
	
	val Scanner in
	
	new() {
		in = new Scanner(System.in);		
	}
	
	override aquireInteractively(String message) {
		var String result = null
		while (result == null) {
			println(message)
			print(">> ");
			result = in.nextLine().trim()					
		}
		return result
	}
	
	override getInteractive(XRawHttpServiceConfigurationScope scope, String key, String message) {
		var result = get(scope, key)
		if (result == null) {
			result = aquireInteractively(message)
			set(scope, key, result)		
			save()	
		}
		
		return result
	}
	
	def close() {
		in.close
	}
	
	abstract protected def void save()
}

@AddConstructor
class EmfStoreInteractiveServiceConfiguration extends AbstractInteractiveServiceConfiguration {
	
	val Service api
	val ServiceCredentials user
	
	private static def get(EList<EStringToSerializableMapEntry> map, String key) {
		return map.findFirst[it.key == key]?.value
	}
	
	private static def put(EList<EStringToSerializableMapEntry> map, String key, String value) {
		val existingEntry = map.findFirst[it.key == key]
		if (existingEntry == null) {
			val newEntry = XRawScriptModelFactory.eINSTANCE.createEStringToSerializableMapEntry
			newEntry.key = key
			newEntry.value = value
			map.add(newEntry)
		} else {
			existingEntry.value = value	
		}
	}  
		
	override get(XRawHttpServiceConfigurationScope scope, String key) {
		if (scope == XRawHttpServiceConfigurationScope.USER) {
			val existingFeature = user.eClass.EAllStructuralFeatures.findFirst[name==key]
			if (existingFeature != null) {
				return user.eGet(existingFeature) as String
			}
		}
		
		val existingFeature = api.eClass.EAllStructuralFeatures.findFirst[name==key]
		if (existingFeature != null) {
			return api.eGet(existingFeature) as String
		}
		
		if (scope == XRawHttpServiceConfigurationScope.USER) {
			val value = user.configuration.get(key)
			if (value == null) {
				return api.configuration.findFirst[it.key == key]?.value
			} else {
				return value
			}
		} else {
			return api.configuration.get(key)
		}
	}
	
	override set(XRawHttpServiceConfigurationScope scope, String key, String value) {
		if (scope == XRawHttpServiceConfigurationScope.USER) {
			val existingFeature = user.eClass.EAllStructuralFeatures.findFirst[name==key]
			if (existingFeature != null) {
				user.eSet(existingFeature, value)
			} else {
				user.configuration.put(key, value.toString)
			}
		} else {
			val existingFeature = api.eClass.EAllStructuralFeatures.findFirst[name==key]
			if (existingFeature != null) {
				api.eSet(existingFeature, value)
			} else {
				api.configuration.put(key, value.toString)
			}
		}
		save()
	}
	
	override protected save() {
		api.eResource.save(null)
	}
	
}