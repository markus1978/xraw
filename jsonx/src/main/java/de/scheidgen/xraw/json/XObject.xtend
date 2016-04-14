package de.scheidgen.xraw.json

import de.scheidgen.xraw.util.AddSuperConstructors
import java.lang.ref.WeakReference
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths
import org.eclipse.xtend.lib.annotations.EqualsHashCode

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
	var ()=>Void save = null
	
	def xSetSave(()=>Void save) {
		this.save = save
	}
	
	static def <E extends XResource> E load(String uri, Class<E> clazz) {
		val result = clazz.getConstructor(JSONObject).newInstance(new JSONObject(Files.readAllLines(Paths.get(uri), StandardCharsets.UTF_8).join("\n"))) as E
		result.xSetSave[
			Files.write(Paths.get(uri), result.xJson.toString(4).getBytes())
			return null
		]
		return result
	}
	
	def xSave() {
		save.apply
	}
	
	def xString() {
		return xJson.toString(4)
	}
}
