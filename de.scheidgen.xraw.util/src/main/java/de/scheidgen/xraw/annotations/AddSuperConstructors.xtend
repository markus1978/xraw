package de.scheidgen.xraw.annotations

import java.lang.annotation.Annotation
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(typeof(AddSuperConstructorCompilationParticipant))
@Target(TYPE)
/**
 * Generates a constructor for all non private constructors of the classes super class.
 */
annotation AddSuperConstructors {
	Class<? extends Annotation>[] value = #[]
}

class AddSuperConstructorCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {

	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements, extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			if (clazz.extendedClass == null) {
				clazz.findAnnotation(AddSuperConstructors.findTypeGlobally).addError("Class has no super class.")
			}			
			val superClassDeclaration = clazz.extendedClass.type as ClassDeclaration
			for (superConstructor: superClassDeclaration.declaredConstructors.filter[visibility != Visibility.PRIVATE]) {
				clazz.addConstructor[
					for(annotation:clazz.findAnnotation(AddSuperConstructors.findTypeGlobally).getClassArrayValue("value")) {
						addAnnotation(newAnnotationReference(annotation.type))
					}
					visibility = superConstructor.visibility
					for(superParam: superConstructor.parameters) {
						val typeParamIndex = superClassDeclaration.typeParameters.indexed.findFirst[it.value.simpleName == superParam.type.name]?.key 
						val type = if (typeParamIndex != null) {
							clazz.extendedClass.actualTypeArguments.get(typeParamIndex) 
						} else {
							superParam.type							
						} 
						addParameter(superParam.simpleName, type)				
					}
					body = ['''
						super(«FOR superParam: superConstructor.parameters SEPARATOR ", "»«superParam.simpleName»«ENDFOR»);
					''']
				]
			}
			
			clazz.removeAnnotation(clazz.findAnnotation(AddSuperConstructors.findTypeGlobally))			
		}	
	}

}