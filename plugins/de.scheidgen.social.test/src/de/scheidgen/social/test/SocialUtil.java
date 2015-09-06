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
import org.scribe.builder.api.TumblrApi;
import org.scribe.builder.api.TwitterApi;

import de.scheidgen.social.core.SocialService;
import de.scheidgen.social.core.socialstore.Profile;
import de.scheidgen.social.core.socialstore.SocialStoreFactory;
import de.scheidgen.social.core.socialstore.SocialStorePackage;
import de.scheidgen.social.twitter.Twitter;
import de.scheidgen.social.twitter.response.TwitterStatus;

public class SocialUtil {

	private static final String DATA_STORE_PATH = "data/store.xmi";
	
	public static Profile openProfile() {
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
		
		return profile;
	}
	
	public static SocialService getTwitterService(Profile profile) {
		return SocialService.authenticate(profile, TwitterApi.class, "uObLVPxuBJqfrEOEB3ms1g", "IAYcfFI5Xhq6g0McCdPVM5EEFOqq8PUkPH7KQu58w", null);
	}
	
	public static SocialService getTumblrService(Profile profile) {
		return SocialService.authenticate(profile, TumblrApi.class, "9L2yRmNiq025MEfqJrbRpozRF2YQXwaOtW3e9exyL9eVrubc4b", "pogU7YRqOPyX5FkMaNwrLQea2MgGxnzqDIbcN5QDoLvHZ3lD8N", "http://www.tumblr.com/connect/login_success.html");		
	}
	
	public static void closeProfile(Profile profile) {
		try {
			profile.eResource().save(null);
		} catch (IOException e) {		
			e.printStackTrace();
		}
	}
	
	public static void main(String[] args) {
		Profile profile = openProfile();
		Twitter twitter = Twitter.create(getTwitterService(profile));
		List<TwitterStatus> userTimeline = twitter.getStatuses().getUserTimeline().send();
		for (TwitterStatus tweet: userTimeline) {
			System.out.println(tweet.getText());
			System.out.println("");
		}
		closeProfile(profile);
	}
}
