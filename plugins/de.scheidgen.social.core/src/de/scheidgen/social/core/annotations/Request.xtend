package de.scheidgen.social.core.annotations

import de.scheidgen.social.core.SocialService
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.EnumerationValueDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.scribe.model.OAuthRequest
import org.scribe.model.Verb

@Active(typeof(RequestCompilationParticipant))
annotation Request {
	Verb method = Verb.GET
	String url = ""
	Class<?> returnType
}

annotation ReturnsList {
	
}

annotation Required {
	
}

class RequestCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {

	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements,
			extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			val declaredFields = new ArrayList<MutableFieldDeclaration>
			declaredFields.addAll(clazz.declaredFields)
			
			clazz.addField("_service") [
				type = newTypeReference(SocialService)
				final = true
			]
			
			for (f : declaredFields) {
				val fieldName = f.simpleName
				
				clazz.addField(fieldName + "WasSet") [
					type = primitiveBoolean
					initializer = '''false'''
				]
			}

			clazz.addConstructor [
				visibility = Visibility.PRIVATE
				addParameter("service", newTypeReference(SocialService))
				body = ['''
					this._service = service;
				''']
			]
			
			clazz.addMethod("create") [
				static = true
				addParameter("service", newTypeReference(SocialService))
				returnType = clazz.newTypeReference
				body = ['''
					return new «clazz.simpleName»(service);
				''']
			]

			for (f : declaredFields) {
				val fieldName = f.simpleName
				val fieldType = f.type

				clazz.addMethod(fieldName) [
					it.addParameter(fieldName, fieldType) 
					returnType = clazz.newTypeReference
					body = ['''
						this.«fieldName» = «fieldName»;
						this.«fieldName + "WasSet"» = true;
						return this;
					''']
				]	
			}
			
			clazz.addMethod("send") [
				val request = clazz.findAnnotation(typeof(Request).findTypeGlobally)
				val requestReturnType = request.getValue('returnType')
				val method = request.getValue('method') as EnumerationValueDeclaration
				val url = request.getValue('url') as String
				val responseType = requestReturnType as TypeReference
				
				if (clazz.findAnnotation(ReturnsList.findTypeGlobally) != null) {
					returnType = newTypeReference(List, {responseType})
				} else {
					returnType = responseType
				}
				
				body = ['''					
					«toJavaCode(OAuthRequest.newTypeReference)» request = new «toJavaCode(OAuthRequest.newTypeReference)»(«toJavaCode(Verb.newTypeReference)».«method.simpleName», "«url»");
					«FOR f: declaredFields»
						«val fieldName = f.simpleName»
						if («fieldName + "WasSet"») {
							request.addQuerystringParameter("«NameUtil::name(context,f)»", ""+«fieldName»);
						}«IF f.findAnnotation(typeof(Required).findTypeGlobally) != null» else {
							throw new IllegalArgumentException("Value for «fieldName» is required.");	
						}«ENDIF»
					«ENDFOR»
					«toJavaCode(org.scribe.model.Response.newTypeReference)» response = _service.execute(request);
					String body = response.getBody();
					System.out.println("%% " + body);
					System.out.println("%%");
					
					«IF clazz.findAnnotation(ReturnsList.findTypeGlobally) != null»
						return «toJavaCode(responseType)».createList(body);
					«ELSE»
						return «toJavaCode(responseType)».create(body);
					«ENDIF»					
				'''	]
			]
		}
	}

}