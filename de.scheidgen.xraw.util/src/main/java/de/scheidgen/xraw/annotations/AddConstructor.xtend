package de.scheidgen.xraw.annotations

import java.lang.annotation.Annotation
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(typeof(AddConstructorCompilationParticipant))
@Target(TYPE)
/**
 * Adds constructors that initialize all final fields that are not already initialized. It creates at least one
 * constructor for the super classes default constructor or one constructor for each declared non private
 * constructor of the super class. If no super class constructor is there, the given visibility is used; default
 * is PUBLIC (i.e. the visibility of the default constructor).
 */
annotation AddConstructor {
	Class<? extends Annotation>[] value = #[]
	Visibility visibility = Visibility.PUBLIC	
}

class AddConstructorCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {

	def addConstructor(MutableClassDeclaration clazz, extension TransformationContext context, ConstructorDeclaration superConstructor) {
		clazz.addConstructor[
			if (superConstructor != null) {
				for (superParam: superConstructor.parameters) {
					addParameter(superParam.simpleName, superParam.type)
				}
				visibility = superConstructor.visibility
			} else {
				visibility = Visibility.valueOf(clazz.findAnnotation(AddConstructor.findTypeGlobally).getEnumValue("value").simpleName)
			}
			
			for(annotation:clazz.findAnnotation(AddConstructor.findTypeGlobally).getClassArrayValue("value")) {
				addAnnotation(newAnnotationReference(annotation.type))
			}
			
			// add a parameter for each uninitialized final declared field
			val finalUninitializedFields = clazz.declaredFields.filter[final && initializer == null].filter[
				// filter for Inject annotations
				!it.annotations.exists[it.annotationTypeDeclaration.simpleName == "Inject"]
			]
			for(field:finalUninitializedFields) {
				addParameter(field.simpleName, field.type)					
			}	

			body = ['''
				«IF superConstructor == null»
					super();
				«ELSE»
					super(«FOR superParam: superConstructor.parameters SEPARATOR ", "»«superParam.simpleName»«ENDFOR»);
				«ENDIF»
				«FOR field : finalUninitializedFields»
					this.«field.simpleName» = «field.simpleName»;
				«ENDFOR»
				«IF clazz.declaredMethods.findFirst[simpleName == "onNew" && parameters.empty] != null»
					onNew();
				«ENDIF»
			''']
		]
	}

	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements, extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			if (clazz.extendedClass == null) {
				clazz.addConstructor(context, null)
			} else {
				val superClassDeclaration = clazz.extendedClass.type as ClassDeclaration
				superClassDeclaration.declaredConstructors.filter[visibility != Visibility.PRIVATE].forEach[
					clazz.addConstructor(context, it)
				]
			}
		}
	}

}