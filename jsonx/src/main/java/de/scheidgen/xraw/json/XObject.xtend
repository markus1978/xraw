package de.scheidgen.xraw.json

import java.lang.ref.WeakReference
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
	
	def xRoot() {
		var current = this
		while (current.xContainer != null) {
			current = current.xContainer
		}
		return current
	}
	
	def xSetContainer(XObject container) {
		if (container == null) {
			this.container = null
		} else {
			this.container = new WeakReference(container)			
		}
	}
}
