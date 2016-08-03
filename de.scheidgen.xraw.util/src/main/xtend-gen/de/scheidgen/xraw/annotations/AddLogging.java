package de.scheidgen.xraw.annotations;

import de.scheidgen.xraw.annotations.AddLoggingCompilationParticipant;
import java.lang.annotation.ElementType;
import java.lang.annotation.Target;
import org.eclipse.xtend.lib.macro.Active;

@Active(AddLoggingCompilationParticipant.class)
@Target(ElementType.TYPE)
public @interface AddLogging {
}
