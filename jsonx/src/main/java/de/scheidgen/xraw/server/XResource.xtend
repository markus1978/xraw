package de.scheidgen.xraw.server

import de.scheidgen.xraw.annotations.AddSuperConstructors
import de.scheidgen.xraw.json.JSONObject
import de.scheidgen.xraw.json.XObject
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths

@AddSuperConstructors
class XResource extends XObject {	
	var ()=>Void save = null
	
	def xSetSave(()=>Void save) {
		this.save = save
	}
	
	static def <E extends XResource> E load(String uri, Class<E> clazz) {
		val result = clazz.getConstructor(JSONObject).newInstance(new JsonOrgObject(Files.readAllLines(Paths.get(uri), StandardCharsets.UTF_8).join("\n"))) as E
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