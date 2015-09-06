package de.scheidgen.social.script

import de.scheidgen.social.script.model.Application
import de.scheidgen.social.script.model.SocialScriptModelFactory
import de.scheidgen.social.script.model.SocialScriptModelPackage
import java.io.File
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.scribe.builder.api.Api
import org.scribe.model.Token
import de.scheidgen.social.core.SocialService
import org.scribe.builder.ServiceBuilder
import de.scheidgen.social.script.model.Service
import de.scheidgen.social.script.model.Profile

class SocialScript {
	
	static def SocialScript create() {
		return new SocialScript(SocialScriptModelFactory.eINSTANCE.createApplication)
	}
	
	static def SocialScript createWithStore(String fileName) {
		EPackage.Registry.INSTANCE.put(SocialScriptModelPackage.eINSTANCE.getNsURI(), SocialScriptModelPackage.eINSTANCE);		
		EPackage.Registry.INSTANCE.put(EcorePackage.eINSTANCE.getNsURI(), EcorePackage.eINSTANCE);
		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("xmi", new XMIResourceFactoryImpl());
		
		val file = new File(if (fileName.endsWith(".xmi")) fileName else fileName + ".xmi")
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
			application = SocialScriptModelFactory.eINSTANCE.createApplication
			resource.contents.add(application)
			resource.save(null);
		}
		
		return new SocialScript(application)
	}
	
	private val Application application;
	
	private new(Application application) {
		this.application = application;
	}
	
	private def createService(Application application) {
		val service = SocialScriptModelFactory.eINSTANCE.createService
		
		application.services.add(service)
		service.eResource.save(null)
		return service
	}
	
	private def createProfile(Application application) {
		val profile = SocialScriptModelFactory.eINSTANCE.createProfile
		
		application.profiles.add(profile)
		profile.eResource.save(null)
		return profile
	}
	
	private def createServiceCredentials(Profile profile, Service service) {
		val credentials = SocialScriptModelFactory.eINSTANCE.createServiceCredentials
		
		profile.services.add(credentials)
		credentials.eResource.save(null)
		return credentials
	}
	
	def <E> E serviceWithLogin(Class<E> serviceClass, String profileId) {
		val scribeServiceClass = serviceClass.declaredMethods.findFirst[it.name.equals("getServiceClass")].invoke(null) as Class<? extends Api>
	
		var serviceVar = application.services.findFirst[it.scribeServiceClass == scribeServiceClass]
		if (serviceVar == null) {
			serviceVar = createService(application)
		}	
		val service = serviceVar
		val oAuthService = new ServiceBuilder().provider(scribeServiceClass)
			.apiKey(service.apiKey)
			.apiSecret(service.apiSecret)
			.callback(service.callbackUrl)
			.scope(service.scope)
			.signatureType(service.signatureType)
			.build
		
		var Token accessToken = null
		if (profileId != null) {
			var profile = application.profiles.findFirst[id.equals(profileId)]
			if (profile == null) {
				profile = createProfile(application)
			}
			var credentials = profile.services.findFirst[it.service == service]
			if (credentials == null) {
				credentials = createServiceCredentials(profile, service)
			}
			
			accessToken = new Token(credentials.getAccessToken(), credentials.getSecret())
		}
		
		return serviceClass.declaredMethods.findFirst[it.name.equals("create")].invoke(new SocialService(oAuthService, accessToken)) as E		
	}
	
	def <E> E service(Class<E> serviceClass) {
		return serviceWithLogin(serviceClass, null)
	}
}