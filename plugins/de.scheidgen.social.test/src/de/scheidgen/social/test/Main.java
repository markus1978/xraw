package de.scheidgen.social.test;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Scanner;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EcorePackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.scribe.builder.api.Api;
import org.scribe.builder.api.TumblrApi;
import org.scribe.builder.api.TwitterApi;

import de.scheidgen.social.core.SocialService;
import de.scheidgen.social.core.socialstore.Profile;
import de.scheidgen.social.core.socialstore.SocialStoreFactory;
import de.scheidgen.social.core.socialstore.SocialStorePackage;
import de.scheidgen.social.twitter.TwitterStatusesShow;
import de.scheidgen.social.twitter.TwitterStatusesUserTimeline;
import de.scheidgen.social.twitter.TwitterTweet;

public class Main {

	private static final String DATA_STORE_PATH = "data/store.xmi";
	
	public static void main(String[] args) {
		EPackage.Registry.INSTANCE.put(SocialStorePackage.eINSTANCE.getNsURI(), SocialStorePackage.eINSTANCE);		
		EPackage.Registry.INSTANCE.put(EcorePackage.eINSTANCE.getNsURI(), EcorePackage.eINSTANCE);
		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("xmi", new XMIResourceFactoryImpl());
		
		URI storeURI = URI.createFileURI(DATA_STORE_PATH);
		ResourceSet rs = new ResourceSetImpl();
		Resource resource = null;
		if (new File(DATA_STORE_PATH).exists()) {
			resource = rs.getResource(storeURI, true);
		} else {
			resource = rs.createResource(storeURI);
		}
		
		Profile profile = null;
		if (!resource.getContents().isEmpty()) {
			profile = (Profile)resource.getContents().get(0);
		}
		if (profile == null) {
			@SuppressWarnings("resource")
			Scanner in = new Scanner(System.in);
			System.out.println("No profile found. We will create one.");
			System.out.println("Choose a login:");
			System.out.print(">>");
			String profileId = in.nextLine().trim();
			
			profile = SocialStoreFactory.eINSTANCE.createProfile();
			profile.setId(profileId);
			resource.getContents().add(profile);
		}
		
		tryService(profile, TwitterApi.class, "uObLVPxuBJqfrEOEB3ms1g", "IAYcfFI5Xhq6g0McCdPVM5EEFOqq8PUkPH7KQu58w", null, "https://api.twitter.com/1.1/statuses/user_timeline.json");
		//tryService(profile, TumblrApi.class, "9L2yRmNiq025MEfqJrbRpozRF2YQXwaOtW3e9exyL9eVrubc4b", "pogU7YRqOPyX5FkMaNwrLQea2MgGxnzqDIbcN5QDoLvHZ3lD8N", "http://www.tumblr.com/connect/login_success.html", "http://api.tumblr.com/v2/user/info");
		
		tryTwitterWrapper(profile, "uObLVPxuBJqfrEOEB3ms1g", "IAYcfFI5Xhq6g0McCdPVM5EEFOqq8PUkPH7KQu58w");
		try {
			resource.save(null);
		} catch (IOException e) {		
			e.printStackTrace();
		}
	}
	
	private static void tryService(Profile profile, Class<? extends Api> apiClass, String key, String secret, String callbackURL, String testURL) {
		SocialService twitter = SocialService.authenticate(profile, apiClass, key, secret, callbackURL);
		String response = twitter.get(testURL);
		System.out.println("Example response from " + apiClass.getSimpleName() + ":");
		System.out.println(response);
		System.out.println("");
	}
	
	private static void tryTwitterWrapper(Profile profile, String key, String secret) {
		SocialService twitterService = SocialService.authenticate(profile, TwitterApi.class, key, secret, null);
		
		//TwitterTweet response = TwitterStatusesShow.create().id("568411632906473472").execute(twitterService);
		List<TwitterTweet> response = TwitterStatusesUserTimeline.create().execute(twitterService);
		System.out.print("## ");
		System.out.println(response.size());
		System.out.println("");
	}

}
