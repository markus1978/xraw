package de.scheidgen.xraw.script

import de.scheidgen.xraw.annotations.AddConstructor
import java.util.Scanner

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
	val XRawStore store
	val Service api
	val ServiceCredentials user
		
	override get(XRawHttpServiceConfigurationScope scope, String key) {
		if (scope == XRawHttpServiceConfigurationScope.USER) {
			if (!user.xJson.isNull(key)) {
				return user.xJson.getString(key)
			}			
		}
		
		if (!api.xJson.isNull(key)) {
			return api.xJson.getString(key)
		}
		
		if (scope == XRawHttpServiceConfigurationScope.USER) {
			val value = user.more.get(key)
			if (value == null) {
				return api.more.get(key)
			} else {
				return value
			}
		} else {
			return api.more.get(key)
		}
	}
	
	override set(XRawHttpServiceConfigurationScope scope, String key, String value) {
		if (scope == XRawHttpServiceConfigurationScope.USER) {
			if (!user.xJson.isNull(key)) {
				user.xJson.put(key, value)
			} else {
				user.more.put(key, value.toString)
			}
		} else {
			
			if (api.xJson.isNull(key)) {
				api.xJson.put(key, value)
			} else {
				api.more.put(key, value.toString)
			}
		}
		save()
	}
	
	override protected save() {
		store.xSave
	}
	
}