package de.scheidgen.xraw.apis.tryout

import de.scheidgen.xraw.json.JSON
import java.util.List

@JSON(mutable=true)
class TryOut {
	String simple
	boolean primitive
	
	List<String> strings
	List<TestE> ohmay
}

enum TestE {
	one, two
}