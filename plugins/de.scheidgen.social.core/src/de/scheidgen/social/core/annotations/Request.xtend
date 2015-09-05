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
import java.util.Collection
import java.util.HashSet

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
			
			clazz.addField("_request") [
				type = newTypeReference(OAuthRequest)
				final = true
			]
			
			clazz.addField("_parameters") [
				type = Collection.newTypeReference(string)
				initializer = ['''new «toJavaCode(HashSet.newTypeReference(string))»()''']
				final = true
			]
			
			clazz.addMethod("create") [
				static = true
				addParameter("service", newTypeReference(SocialService))
				returnType = clazz.newTypeReference
				body = ['''
					return new «toJavaCode(clazz.newTypeReference)»(service);
				''']
			]
			
			
			clazz.addConstructor [
				visibility = Visibility.PRIVATE
				addParameter("service", newTypeReference(SocialService))
				body = [
					val request = clazz.findAnnotation(typeof(Request).findTypeGlobally)					
					val method = request.getValue('method') as EnumerationValueDeclaration
					val url = request.getValue('url') as String
				
					return '''
						this._service = service;
						this._request = new «toJavaCode(OAuthRequest.newTypeReference)»(«toJavaCode(Verb.newTypeReference)».«method.simpleName», "«url»");
					'''
				]
			] 
			
			for (field : declaredFields) {
				val localName = NameUtil::snakeCaseToCamelCase(field.simpleName)
				clazz.addMethod(localName) [
					visibility = Visibility.PUBLIC
					addParameter(localName, field.type)
					docComment = field.docComment
					returnType = clazz.newTypeReference
					val remoteName = NameUtil::name(context, field)
					body = ['''
						_request.addQuerystringParameter("«remoteName»", «toJavaCode(string)».valueOf(«localName»));
						_parameters.add("«remoteName»");
						return this;
					'''] 
				]								
			}
			
			clazz.addMethod("send") [
				val request = clazz.findAnnotation(typeof(Request).findTypeGlobally)
				val requestReturnType = request.getValue('returnType')
				val responseType = requestReturnType as TypeReference
				
				if (clazz.findAnnotation(ReturnsList.findTypeGlobally) != null) {
					returnType = newTypeReference(List, {responseType})
				} else {
					returnType = responseType
				}
				
				body = ['''					
					// check required parameters were set
					«FOR field: declaredFields»
						«IF field.findAnnotation(Required.findTypeGlobally) != null»
							if (!_parameters.contains("«NameUtil::name(context, field)»")) {
								throw new IllegalArgumentException("Value for «NameUtil::snakeCaseToCamelCase(field.simpleName)» is required.");
							}
						«ENDIF»
					«ENDFOR»
					
					// send request and process response
					«toJavaCode(org.scribe.model.Response.newTypeReference)» response = _service.execute(_request);
					String body = response.getBody();					
					«IF clazz.findAnnotation(ReturnsList.findTypeGlobally) != null»
						return «toJavaCode(responseType)».createList(body);
					«ELSE»
						return «toJavaCode(responseType)».create(body);
					«ENDIF»					
				'''	]
			]
			
			for (field: declaredFields) {
				field.remove
			}
		}
	}

}