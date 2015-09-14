package de.scheidgen.xraw.script

import de.scheidgen.xraw.json.Converter
import de.scheidgen.xraw.json.JSON
import de.scheidgen.xraw.json.WithConverter
import java.util.List
import org.json.JSONObject
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.charset.StandardCharsets
import java.util.Map

@JSON(mutable=true) class XRawStore {
	Application application
	String file
	static def load(String file) {
		val result = new XRawStore(new JSONObject(Files.readAllLines(Paths.get(file), StandardCharsets.UTF_8).join("\n")))
		result.file = file
		return result
	}
	
	def save() {
		Files.write(Paths.get(file), xJson.toString.getBytes());
	}
	
}

@JSON(mutable=true) class Application {
	List<Profile> profiles
	List<Service> services	
}

@JSON(mutable=true) class AbstractConfiguration {
	Map<String,String> more
}

@JSON(mutable=true) class Profile {
	String id
	List<ServiceCredentials> services
}

@JSON(mutable=true) class Service extends AbstractConfiguration {
	String id
	@WithConverter(ClassConverter) Class<?> serviceClass
	String apiKey
	String apiSecret
	String callbackUrl
	String scope
}

@JSON(mutable=true) class ServiceCredentials extends AbstractConfiguration {
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