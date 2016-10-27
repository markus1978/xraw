package de.scheidgen.xraw.server

import de.scheidgen.xraw.client.json.JSONObject
import de.scheidgen.xraw.client.json.XObject
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths

class XResource extends XObject {	
	var ()=>Void save = null

	new (JSONObject json) {
		super(json)
	}
	
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