package de.scheidgen.xraw.json

import java.lang.ref.WeakReference
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.json.JSONObject
import java.beans.ConstructorProperties
import de.scheidgen.xraw.util.AddSuperConstructors

@EqualsHashCode
class XObject {
	private var WeakReference<XObject> container = null
	protected val JSONObject json

	new(JSONObject json, XObject container) {
		this.json = json
		xSetContainer(container)
	}
	
	new(JSONObject json) {
		this(json, null)
	}
	
	new() {
		this(new JSONObject, null)
	}
	
	public def xGetString(String key) {
		if (json.isNull(key)) {
			return null;
		} else {
			return json.get(key).toString
		}
	}
	
	public def xJson() {
		return json
	}

	def xContainer() {
		return if (container == null) null else container.get
	}
	
	def xResource() {
		var result = this
		while (result != null && !(result instanceof XResource)) {
			result = result.xContainer
		}
		return result
	}
	
	def xSetContainer(XObject container) {
		if (container == null) {
			this.container = null
		} else {
			this.container = new WeakReference(container)			
		}
	}
}

@AddSuperConstructors
class XResource extends XObject {	
	var String uri = null
	
	def xSetURI(String uri) {
		this.uri = uri
	}
	
	def xURI() {
		return uri
	}
	
	static def <E extends XObject> E load(String uri, Class<E> clazz) {
		return clazz.getConstructor(JSONObject).newInstance(new JSONObject(Files.readAllLines(Paths.get(uri), StandardCharsets.UTF_8).join("\n"))) as E
	}
	
	def xSave() {
		Files.write(Paths.get(uri), xJson.toString(4).getBytes());	
	}
}
