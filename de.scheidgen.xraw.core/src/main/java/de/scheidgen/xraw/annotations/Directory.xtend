package de.scheidgen.xraw.annotations

import de.scheidgen.xraw.AbstractService
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import de.scheidgen.xraw.script.XRawHttpServiceConfiguration
import de.scheidgen.xraw.http.XRawHttpService

@Active(typeof(DirectoryCompilationParticipant))
@Target(TYPE)
annotation Directory {}

@Target(TYPE) annotation Service {}

class DirectoryCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {
	
	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements, extension TransformationContext context) {
		
		for (clazz : annotatedTargetElements) {
			val declaredFields = new ArrayList<MutableFieldDeclaration>
			declaredFields.addAll(clazz.declaredFields)
			
			val serviceAnnotation = clazz.findAnnotation(Service.findTypeGlobally)
			if (serviceAnnotation != null) {
				clazz.extendedClass = AbstractService.newTypeReference

				clazz.addConstructor [
					addParameter("service", XRawHttpService.newTypeReference)
					visibility = Visibility.PUBLIC
					body = ['''
						super(service);
						«FOR field: declaredFields.filter[(type.type as ClassDeclaration).findAnnotation(Directory.findTypeGlobally)!=null]»
							this.«field.simpleName» = new «toJavaCode(field.type)»(_httpService); 
						«ENDFOR»
					''']
				]
				clazz.addConstructor [
					addParameter("serviceConfiguration", XRawHttpServiceConfiguration.newTypeReference)
					visibility = Visibility.PUBLIC
					body = ['''
						super(serviceConfiguration);
						«FOR field: declaredFields.filter[(type.type as ClassDeclaration).findAnnotation(Directory.findTypeGlobally)!=null]»
							this.«field.simpleName» = new «toJavaCode(field.type)»(_httpService); 
						«ENDFOR»
					''']
				]
			} else {
				clazz.addField("_httpService") [
					type = XRawHttpService.newTypeReference
					final = true
				]
				clazz.addConstructor [
					addParameter("service", XRawHttpService.newTypeReference)
					visibility = Visibility.PUBLIC
					body = ['''
						this._httpService = service;
						«FOR field: declaredFields.filter[(type.type as ClassDeclaration).findAnnotation(Directory.findTypeGlobally)!=null]»
							this.«field.simpleName» = new «toJavaCode(field.type)»(_httpService); 
						«ENDFOR»
					''']
				]
			}
			
			for (field: declaredFields) {
				if ((field.type.type as ClassDeclaration).findAnnotation(Directory.findTypeGlobally)!=null) {
					field.visibility = Visibility.PRIVATE
					field.final = true
					clazz.addMethod("get" + field.simpleName.toFirstUpper) [
						returnType = field.type
						docComment = (field.type.type as ClassDeclaration).docComment
						body = ['''
							return «field.simpleName»;
						''']
					]
				} else {
					clazz.addMethod("get" + field.simpleName.toFirstUpper) [
						returnType = field.type
						docComment = (field.type.type as ClassDeclaration).docComment
						body = ['''
							return new «toJavaCode(field.type)»(_httpService);
						''']
					]
					field.remove
				}								
			}
		}
	}
	
}