package de.scheidgen.xraw.script

import de.scheidgen.xraw.model.Service
import de.scheidgen.xraw.model.ServiceCredentials
import de.scheidgen.xraw.util.AddConstructor
import java.io.Serializable
import java.util.Scanner

enum ServiceConfigurationScope {
	API, USER
}

interface ServiceConfiguration {
	public static val apiKey = "apiKey"
	public static val apiSecret = "apiSecret"
	public static val userToken = "accessToken"
	public static val userSecret = "secret"
	public static val callbackUrl = "callbackUrl"
	public static val scope = "scope"
	
	def Serializable get(ServiceConfigurationScope scope, String key)
	def void set(ServiceConfigurationScope scope, String key, Serializable value)	
}

interface InteractiveServiceConfiguration extends ServiceConfiguration {
	def <E extends Serializable> E aquireInteractively(String message, (String)=>E convert)
	def <E extends Serializable> E getInteractive(ServiceConfigurationScope scope, String key, String message, (String)=>E convert)
}

abstract class AbstractInteractiveServiceConfiguration implements InteractiveServiceConfiguration {
	
	val Scanner in
	
	new() {
		in = new Scanner(System.in);		
	}
	
	override <E extends Serializable> E aquireInteractively(String message, (String)=>E convert) {
		var E result = null
		while (result == null) {
			println(message)
			print(">> ");
			val stringValue = in.nextLine().trim()
			try {
				result = convert.apply(stringValue)
			} catch (Exception e) {
				println(stringValue + " is not a valid value. Please repeat.")
			}			
		}
		return result
	}
	
	override <E extends Serializable> E getInteractive(ServiceConfigurationScope scope, String key, String message, (String)=>E convert) {
		var result = get(scope, key)
		if (result == null) {
			result = aquireInteractively(message, convert)
			set(scope, key, result)			
		}
		
		return result as E
	}
	
	def close() {
		in.close
	}
}

@AddConstructor
class EmfStoreInteractiveServiceConfiguration extends AbstractInteractiveServiceConfiguration {
	
	val Service api
	val ServiceCredentials user
		
	override get(ServiceConfigurationScope scope, String key) {
		if (scope == ServiceConfigurationScope.USER) {
			val existingFeature = user.eClass.EAllStructuralFeatures.findFirst[name==key]
			if (existingFeature != null) {
				return user.eGet(existingFeature) as Serializable
			}
		}
		
		val existingFeature = api.eClass.EAllStructuralFeatures.findFirst[name==key]
		if (existingFeature != null) {
			return api.eGet(existingFeature) as Serializable
		}
		
		if (scope == ServiceConfigurationScope.USER) {
			val value = user.configuration.get(key)
			if (value == null) {
				return api.configuration.get(key)
			} else {
				return value
			}
		} else {
			return api.configuration.get(key)
		}
	}
	
	override set(ServiceConfigurationScope scope, String key, Serializable value) {
		if (scope == ServiceConfigurationScope.USER) {
			val existingFeature = user.eClass.EAllStructuralFeatures.findFirst[name==key]
			if (existingFeature != null) {
				user.eSet(existingFeature, value)
			} else {
				user.configuration.put(key, value)
			}
		} else {
			val existingFeature = api.eClass.EAllStructuralFeatures.findFirst[name==key]
			if (existingFeature != null) {
				api.eSet(existingFeature, value)
			} else {
				api.configuration.put(key, value)
			}
		}
	}
}