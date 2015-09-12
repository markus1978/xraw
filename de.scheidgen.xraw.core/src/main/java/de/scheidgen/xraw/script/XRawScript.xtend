package de.scheidgen.xraw.script

import de.scheidgen.xraw.AbstractService
import de.scheidgen.xraw.model.Application
import de.scheidgen.xraw.model.XRawScriptModelFactory
import de.scheidgen.xraw.model.XRawScriptModelPackage
import java.io.File
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl

class XRawScript {
	
	static def <S extends AbstractService> S get(XRawHttpServiceConfiguration config, Class<S> serviceClass) {
		val serviceClassConfigurationConstructor = serviceClass.declaredConstructors.findFirst[
			it.parameters.size == 1 && it.parameters.get(0).type.isAssignableFrom(config.class)
		]
		return serviceClassConfigurationConstructor.newInstance(config) as S
	}
	
	static def <S extends AbstractService> S get(String storeFile, String userName, Class<S> serviceClass) {
		EPackage.Registry.INSTANCE.put(XRawScriptModelPackage.eINSTANCE.getNsURI(), XRawScriptModelPackage.eINSTANCE);		
		EPackage.Registry.INSTANCE.put(EcorePackage.eINSTANCE.getNsURI(), EcorePackage.eINSTANCE);
		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("xmi", new XMIResourceFactoryImpl());
		
		val file = new File(if (storeFile.endsWith(".xmi")) storeFile else storeFile + ".xmi")
		val storeURI = URI.createFileURI(file.path)
		val rs = new ResourceSetImpl()
		var Resource resource = null;
		if (file.exists) {
			resource = rs.getResource(storeURI, true);
		} else {
			resource = rs.createResource(storeURI);
		}
		
		var Application application = null;
		if (!resource.contents.empty) {
			application = resource.contents.get(0) as Application
		} else {
			application = XRawScriptModelFactory.eINSTANCE.createApplication
			resource.contents.add(application)
			resource.save(null);
		}
		
		var profile = application.profiles.findFirst[it.id==userName]
		if (profile == null) {
			profile = XRawScriptModelFactory.eINSTANCE.createProfile
			profile.id = userName
			application.profiles.add(profile)
			resource.save(null)
		}
		
		var service = application.services.findFirst[it.serviceClass == serviceClass]
		if (service == null) {
			service = XRawScriptModelFactory.eINSTANCE.createService
			service.serviceClass = serviceClass
			application.services.add(service)
			resource.save(null)
		}
		val serviceVal = service
		
		var serviceCredentials = profile.services.findFirst[it.service == serviceVal]
		if (serviceCredentials == null) {
			serviceCredentials = XRawScriptModelFactory.eINSTANCE.createServiceCredentials
			serviceCredentials.service = service
			profile.services.add(serviceCredentials)
			resource.save(null)
		}
		
		val configuration = new EmfStoreInteractiveServiceConfiguration(service, serviceCredentials)
		return get(configuration, serviceClass)
	}
}