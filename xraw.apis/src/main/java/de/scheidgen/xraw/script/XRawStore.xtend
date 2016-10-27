package de.scheidgen.xraw.script

import de.scheidgen.xraw.annotations.JSON
import de.scheidgen.xraw.annotations.Resource
import de.scheidgen.xraw.annotations.WithConverter
import de.scheidgen.xraw.client.json.Converter
import java.util.List
import java.util.Map

@Resource class XRawStore {
	Application application
}

@JSON class Application {
	List<Profile> profiles
	List<Service> services
}

@JSON class AbstractConfiguration {
	Map<String,String> more
}

@JSON class Profile {
	String id
	List<ServiceCredentials> services
}

@JSON class Service extends AbstractConfiguration {
	String id
	@WithConverter(ClassConverter) Class<?> serviceClass
	String apiKey
	String apiSecret
	String callbackUrl
	String scope
}

@JSON class ServiceCredentials extends AbstractConfiguration {
	@WithConverter(ClassConverter) Class<?> serviceClass
	String accessToken
	String secret
}

class ClassConverter implements Converter<Class<?>> {

	override toValue(String str) {
		return Thread.currentThread.contextClassLoader.loadClass(str)
	}

	override toString(Class<?> value) {
		return value.canonicalName
	}

}