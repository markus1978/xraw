package de.scheidgen.xraw.script

import de.scheidgen.xraw.client.core.AbstractService
import de.scheidgen.xraw.client.core.XRawHttpService
import de.scheidgen.xraw.server.JsonOrgObject
import de.scheidgen.xraw.server.XResource
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths

class XRawScript {
	
	static def <S extends AbstractService> S get(XRawHttpService httpService, Class<S> serviceClass) {
		val serviceClassConfigurationConstructor = serviceClass.declaredConstructors.findFirst[
			it.parameterTypes.size == 1 && it.parameterTypes.get(0).isAssignableFrom(httpService.class)
		]
		return serviceClassConfigurationConstructor.newInstance(httpService) as S
	}
	
	static def <S extends AbstractService> XRawHttpServiceConfiguration getConfiguration(String storeFile, String userName, Class<S> serviceClass) {
		
		val file = new File(if (storeFile.endsWith(".json")) storeFile else storeFile + ".json")
		val store =	if (file.exists) {
			XResource::load(file.absolutePath, XRawStore)
		} else {
			val result = new XRawStore(new JsonOrgObject)
			result.application = new Application(new JsonOrgObject)
			result.xSetSave[
				Files.write(Paths.get(file.absolutePath), result.xJson.toString(4).getBytes())
				return null			
			]
			result
		}
		
		val application = store.application
		
		var profile = application.profiles.findFirst[it.id==userName]
		if (profile == null) {
			profile = new Profile(new JsonOrgObject)
			profile.id = userName
			application.profiles.add(profile)
		}
		
		var service = application.services.findFirst[it.serviceClass == serviceClass]
		if (service == null) {
			service = new Service(new JsonOrgObject)
			service.serviceClass = serviceClass			
			application.services.add(service)
		}
		val serviceVal = service
		
		var serviceCredentials = profile.services.findFirst[it.serviceClass == serviceVal.serviceClass]
		if (serviceCredentials == null) {
			serviceCredentials = new ServiceCredentials(new JsonOrgObject)
			serviceCredentials.serviceClass = service.serviceClass
			profile.services.add(serviceCredentials)
		}
		store.xSave
		
		return new EmfStoreInteractiveServiceConfiguration(store, service, serviceCredentials)		
	}
	
	static def <S extends AbstractService> S get(String storeFile, String userName, Class<S> serviceClass, (XRawHttpServiceConfiguration)=>XRawHttpService serviceFactory) {		
		val configuration = getConfiguration(storeFile, userName, serviceClass)
		return get(serviceFactory.apply(configuration), serviceClass)
	}
}