package de.scheidgen.xraw.annotations;

import de.scheidgen.xraw.annotations.AddConstructorCompilationParticipant;
import java.lang.annotation.Annotation;
import java.lang.annotation.ElementType;
import java.lang.annotation.Target;
import org.eclipse.xtend.lib.macro.Active;
import org.eclipse.xtend.lib.macro.declaration.Visibility;

@Active(AddConstructorCompilationParticipant.class)
@Target(ElementType.TYPE)
public @interface AddConstructor {
  public Class<? extends Annotation>[] value() default {};
  public Visibility visibility() default Visibility.PUBLIC;
}
