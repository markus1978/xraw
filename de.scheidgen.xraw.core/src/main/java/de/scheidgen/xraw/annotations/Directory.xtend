package de.scheidgen.xraw.annotations

import de.scheidgen.xraw.SocialService
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.scribe.builder.api.Api

@Active(typeof(DirectoryCompilationParticipant))
annotation Directory {
	
}

annotation Service {
	Class<? extends Api> value
}

class DirectoryCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {
	
	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements, extension TransformationContext context) {
		
		for (clazz : annotatedTargetElements) {
			val declaredFields = new ArrayList<MutableFieldDeclaration>
			declaredFields.addAll(clazz.declaredFields)
			
			clazz.addField("_service") [
				type = SocialService.newTypeReference
				final = true
			]
			
			val serviceAnnotation = clazz.findAnnotation(Service.findTypeGlobally)
			if (serviceAnnotation != null) {
				clazz.addMethod("getServiceClass") [
					visibility = Visibility.PUBLIC
					static = true
					returnType = Class.newTypeReference(newWildcardTypeReferenceWithLowerBound(serviceAnnotation.getClassValue("value")))
					body = ['''
						return «toJavaCode(serviceAnnotation.getClassValue("value"))».class;
					''']
				]
			}
			
			clazz.addMethod("create") [
				static = true
				visibility = Visibility.PUBLIC
				addParameter("service", SocialService.newTypeReference)
				returnType = clazz.newTypeReference
				body = ['''
					return new «toJavaCode(clazz.newTypeReference)»(service);
				''']
			]
			
			clazz.addConstructor [
				addParameter("service", SocialService.newTypeReference)
				visibility = Visibility.PRIVATE
				body = ['''
					this._service = service;
					«FOR field: declaredFields.filter[(type.type as ClassDeclaration).findAnnotation(Directory.findTypeGlobally)!=null]»
						this.«field.simpleName» = «toJavaCode(field.type)».create(_service); 
					«ENDFOR»
				''']
			]
			
			for (field: declaredFields) {
				if ((field.type.type as ClassDeclaration).findAnnotation(Directory.findTypeGlobally)!=null) {
					field.visibility = Visibility.PRIVATE
					field.final = true
					clazz.addMethod("get" + field.simpleName.toFirstUpper) [
						returnType = field.type
						body = ['''
							return «field.simpleName»;
						''']
					]
				} else {
					clazz.addMethod("get" + field.simpleName.toFirstUpper) [
						returnType = field.type
						body = ['''
							return «toJavaCode(field.type)».create(_service);
						''']
					]
					field.remove
				}								
			}
		}
	}
	
}