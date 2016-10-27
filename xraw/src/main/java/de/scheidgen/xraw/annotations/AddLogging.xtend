package de.scheidgen.xraw.annotations

import java.lang.annotation.Target
import java.util.List
import java.util.logging.Logger
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(typeof(AddLoggingCompilationParticipant))
@Target(TYPE)
annotation AddLogging {
		
}

class AddLoggingCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {

	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements, extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			val annotation = clazz.annotations.findFirst[it.annotationTypeDeclaration == AddLogging.findTypeGlobally]
			clazz.removeAnnotation(annotation)
			clazz.addField("log") [
				static = true
				visibility = Visibility.PRIVATE
				type = Logger.newTypeReference				
				initializer = ['''«toJavaCode(Logger.newTypeReference)».getLogger(«toJavaCode(clazz.newTypeReference)».class.getName())''']
			]
		}
	}

}