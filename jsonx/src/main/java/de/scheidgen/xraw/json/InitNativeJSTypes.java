package de.scheidgen.xraw.json;

public class InitNativeJSTypes {

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
}
