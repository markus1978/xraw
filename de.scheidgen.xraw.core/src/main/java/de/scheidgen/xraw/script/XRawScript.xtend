package de.scheidgen.xraw.script

import de.scheidgen.xraw.AbstractService
import java.io.File

class XRawScript {
	
	static def <S extends AbstractService> S get(XRawHttpServiceConfiguration config, Class<S> serviceClass) {
		val serviceClassConfigurationConstructor = serviceClass.declaredConstructors.findFirst[
			it.parameters.size == 1 && it.parameters.get(0).type.isAssignableFrom(config.class)
		]
		return serviceClassConfigurationConstructor.newInstance(config) as S
	}
	
	static def <S extends AbstractService> S get(String storeFile, String userName, Class<S> serviceClass) {
		
		val file = new File(if (storeFile.endsWith(".json")) storeFile else storeFile + ".json")
		val store =	if (file.exists) {
			XRawStore::load(file.absolutePath)
		} else {
			val result = new XRawStore
			result.application = new Application
			result
		}
		store.file = file.absolutePath
		
		val application = store.application
		
		var profile = application.profiles.findFirst[it.id==userName]
		if (profile == null) {
			profile = new Profile
			profile.id = userName
			application.profiles.add(profile)
		}
		
		var service = application.services.findFirst[it.serviceClass == serviceClass]
		if (service == null) {
			service = new Service
			service.serviceClass = serviceClass			
			application.services.add(service)
		}
		val serviceVal = service
		
		var serviceCredentials = profile.services.findFirst[it.serviceClass == serviceVal.serviceClass]
		if (serviceCredentials == null) {
			serviceCredentials = new ServiceCredentials
			serviceCredentials.serviceClass = service.serviceClass
			profile.services.add(serviceCredentials)
		}
		store.save
		
		val configuration = new EmfStoreInteractiveServiceConfiguration(store, service, serviceCredentials)
		return get(configuration, serviceClass)
	}
}