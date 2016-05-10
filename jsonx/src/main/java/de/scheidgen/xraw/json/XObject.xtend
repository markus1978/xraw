package de.scheidgen.xraw.json

import de.scheidgen.xraw.annotations.AddConstructor
import org.eclipse.xtend.lib.annotations.EqualsHashCode

@AddConstructor
@EqualsHashCode
class XObject {
	protected val JSONObject json
	
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

}
