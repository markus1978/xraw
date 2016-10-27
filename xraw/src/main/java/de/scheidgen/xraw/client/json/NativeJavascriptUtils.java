package de.scheidgen.xraw.client.json;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.json.client.JSONObject;

public class NativeJavascriptUtils {

	public native static void init(String[] qualifiedName) /*-{
		var current = $wnd;
		for (var i = 0; i < qualifiedName.length; i++) {
			var name = qualifiedName[i];
			if (!current[name]) {
				if (i == qualifiedName.length - 1) {
					current[name] = function() {};
				} else {
					current[name] = {};
				}
			}
			current = current[name];
		}		
	}-*/;
	
	public static native JavaScriptObject unwrap(com.google.gwt.json.client.JSONObject jsonObject) /*-{		
		return @com.google.gwt.json.client.JSONObject::unwrap(Lcom/google/gwt/json/client/JSONObject;)(jsonObject);
	}-*/;
	
	public static GwtJsonObject wrap(JavaScriptObject javaScriptObject) {
		return new GwtJsonObject(new JSONObject(javaScriptObject));
	}
}
