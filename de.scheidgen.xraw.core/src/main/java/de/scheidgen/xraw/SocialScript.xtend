package de.scheidgen.xraw

import de.scheidgen.xraw.model.Application
import de.scheidgen.xraw.model.Profile
import de.scheidgen.xraw.model.Service
import java.io.File
import java.util.Scanner
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.scribe.builder.ServiceBuilder
import org.scribe.builder.api.Api
import org.scribe.model.SignatureType
import org.scribe.model.Token
import org.scribe.model.Verifier
import org.scribe.oauth.OAuthService
import de.scheidgen.xraw.model.XRawScriptModelFactory
import de.scheidgen.xraw.model.XRawScriptModelPackage

class SocialScript {
	
	static def SocialScript create() {
		return new SocialScript(XRawScriptModelFactory.eINSTANCE.createApplication)
	}
	
	static def SocialScript createWithStore(String fileName) {
		EPackage.Registry.INSTANCE.put(XRawScriptModelPackage.eINSTANCE.getNsURI(), XRawScriptModelPackage.eINSTANCE);		
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
			application = XRawScriptModelFactory.eINSTANCE.createApplication
			resource.contents.add(application)
			resource.save(null);
		}
		
		return new SocialScript(application)
	}
	
	private val Application application;
	
	private new(Application application) {
		this.application = application;
	}
	
	private def createService(Application application, Class<? extends Api> scribeServiceClass) {
		val service = XRawScriptModelFactory.eINSTANCE.createService
		service.scribeServiceClass = scribeServiceClass
		
		val in = new Scanner(System.in);
		println("No data for " + scribeServiceClass.simpleName + " found.")
		println("Enter a API key: ")
		print(">>");
		service.apiKey = in.nextLine().trim()
		
		println("Enter a API secret: ")
		print(">>")
		service.apiSecret = in.nextLine().trim()
		
		println("Enter a callback URL (if required by API): ")
		print(">>")
		val callbackLine = in.nextLine().trim()
		if (!callbackLine.equals("")) {
			service.callbackUrl = callbackLine
		}
		
		println("Enter a scope (if required by API): ")
		print(">>")
		val scopeLine = in.nextLine().trim()
		if (!scopeLine.equals("")) {
			service.scope = scopeLine
		}
		
		println("Enter a signature type [Header|QueryString] (if required by API): ")
		print(">>")
		val signatureLine = in.nextLine().trim()
		if (signatureLine.equals("Header")) {
			service.signatureType = SignatureType.Header
		} else if (signatureLine.equals("QueryString")) {
			service.signatureType = SignatureType.QueryString
		} else {
			service.signatureType = SignatureType.Header
		}
				
		application.services.add(service)
		service.eResource.save(null)
		return service
	}
	
	private def createProfile(Application application, String profileId) {
		val profile = XRawScriptModelFactory.eINSTANCE.createProfile
		profile.id = profileId
		application.profiles.add(profile)
		profile.eResource.save(null)
		return profile
	}
	
	private def createServiceCredentials(Profile profile, Service service, OAuthService oAuthService) {
		val credentials = XRawScriptModelFactory.eINSTANCE.createServiceCredentials
		credentials.service = service
		
		val requestToken = oAuthService.requestToken
		val authorizationUrl = oAuthService.getAuthorizationUrl(requestToken)
		
		val in = new Scanner(System.in);
		println("No credentials for " + service.scribeServiceClass.simpleName + " and user " + profile.id + " found.")
		println("Please go to the following URL, log in, and retrieve the 'verifier': ")
		println(authorizationUrl)
		println
		
		println("Enter the 'verifier'")
		print(">>");
		val verifier = new Verifier(in.nextLine().trim())
		val accessToken = oAuthService.getAccessToken(requestToken, verifier)
		
		credentials.accessToken = accessToken.token
		credentials.secret = accessToken.secret
		
		profile.services.add(credentials)
		credentials.eResource.save(null)
		return credentials
	}
	
	def <E> E serviceWithLogin(Class<E> serviceClass, String profileId) {
		val scribeServiceClass = serviceClass.declaredMethods.findFirst[it.name.equals("getServiceClass")]?.invoke(null) as Class<? extends Api>
		if (scribeServiceClass == null) {
			throw new IllegalArgumentException("The class " + serviceClass.simpleName + " does not have the @Service annotation.")
		}
	
		var serviceVar = application.services.findFirst[it.scribeServiceClass == scribeServiceClass]
		if (serviceVar == null) {
			serviceVar = createService(application, scribeServiceClass)
		}	
		val service = serviceVar
		val serviceBuilder = new ServiceBuilder().provider(scribeServiceClass)
			.apiKey(service.apiKey)
			.apiSecret(service.apiSecret)
		if (service.callbackUrl != null) {
			serviceBuilder.callback(service.callbackUrl)
		} 
		if (service.scope != null) {
			serviceBuilder.scope(service.scope)
		}
		serviceBuilder.signatureType(service.signatureType)
		val oAuthService =  serviceBuilder.build
		
		var Token accessToken = null
		if (profileId != null) {
			var profile = application.profiles.findFirst[id.equals(profileId)]
			if (profile == null) {
				profile = createProfile(application, profileId)
			}
			var credentials = profile.services.findFirst[it.service == service]
			if (credentials == null) {
				credentials = createServiceCredentials(profile, service, oAuthService)
			}
			
			accessToken = new Token(credentials.getAccessToken(), credentials.getSecret())
		}
		
		return serviceClass.declaredMethods.findFirst[it.name.equals("create")].invoke(null, new SocialService(oAuthService, accessToken)) as E		
	}
	
	def <E> E service(Class<E> serviceClass) {
		return serviceWithLogin(serviceClass, null)
	}
}