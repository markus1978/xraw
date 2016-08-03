package de.scheidgen.xraw.annotations;

import de.scheidgen.xraw.annotations.AddSuperConstructorCompilationParticipant;
import java.lang.annotation.Annotation;
import java.lang.annotation.ElementType;
import java.lang.annotation.Target;
import org.eclipse.xtend.lib.macro.Active;

@Active(AddSuperConstructorCompilationParticipant.class)
@Target(ElementType.TYPE)
public @interface AddSuperConstructors {
  public Class<? extends Annotation>[] value() default {};
}
