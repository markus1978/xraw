package de.scheidgen.xraw.annotations

import de.scheidgen.xraw.json.Converter
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active

annotation Name {
	String value
}

@Active(typeof(JSONWrapperCompilationParticipant))
@Target(TYPE)
annotation JSON {

}

@Active(typeof(JSONWrapperCompilationParticipant))
@Target(TYPE)
annotation Resource {
	
}

@Target(FIELD)
annotation WithConverter {
	Class<? extends Converter<?>> value
}


