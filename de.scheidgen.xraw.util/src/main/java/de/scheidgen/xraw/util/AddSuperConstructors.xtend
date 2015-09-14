package de.scheidgen.xraw.util

import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import java.lang.annotation.Target

@Active(typeof(AddSuperConstructorCompilationParticipant))
@Target(TYPE)
/**
 * Generates a constructor for all non private constructors of the classes super class.
 */
annotation AddSuperConstructors {
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
					visibility = superConstructor.visibility
					for(superParam: superConstructor.parameters) {
						addParameter(superParam.simpleName, superParam.type)				
					}
					body = ['''
						super(«FOR superParam: superConstructor.parameters SEPARATOR ", "»«superParam.simpleName»«ENDFOR»);
					''']
				]
			}			
		}
	}

}