package de.scheidgen.social.core.annotations

import de.scheidgen.social.core.SocialService
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.EnumerationValueDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.scribe.model.OAuthRequest
import org.scribe.model.Response
import org.scribe.model.Verb
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import java.util.ArrayList
import com.google.common.collect.Iterables

@Active(typeof(RequestCompilationParticipant))
annotation Request {
	Verb method = Verb.GET
	String url = ""
	Class<?> returnType
}

annotation Name {
	String value
}

annotation Required {
	
}

class RequestCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {

	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements,
			extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			val declaredFields = new ArrayList<MutableFieldDeclaration>
			declaredFields.addAll(clazz.declaredFields)

			for (f : declaredFields) {
				val fieldName = f.simpleName
				
				clazz.addField(fieldName + "WasSet") [
					type = primitiveBoolean
					initializer = '''false'''
				]
			}

			clazz.addConstructor [
				visibility = Visibility.PRIVATE
				body = ['''''']
			]
			
			clazz.addMethod("create") [
				static = true
				returnType = clazz.newTypeReference
				body = ['''
					return new «clazz.simpleName»();
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
			
			clazz.addMethod("execute") [
				addParameter("service", newTypeReference(typeof(SocialService)))
				val request = clazz.findAnnotation(typeof(Request).findTypeGlobally)
				val requestReturnType = request.getValue('returnType')
				val method = request.getValue('method') as EnumerationValueDeclaration
				val url = request.getValue('url') as String
				returnType = requestReturnType as TypeReference
				body = ['''					
					«toJavaCode(OAuthRequest.newTypeReference)» request = new «toJavaCode(OAuthRequest.newTypeReference)»(«toJavaCode(Verb.newTypeReference)».«method.simpleName», "«url»");
					«FOR f: declaredFields»
						«val fieldName = f.simpleName»
						if («fieldName + "WasSet"») {
							request.addBodyParameter("«context.parameterName(f)»", ""+«fieldName»);
						}«IF f.findAnnotation(typeof(Required).findTypeGlobally) != null» else {
							throw new IllegalArgumentException("Value for «fieldName» is required.");	
						}«ENDIF»
					«ENDFOR»
					«toJavaCode(Response.newTypeReference)» response = service.execute(request);
					return response.getBody();
				'''	]
			]
		}
	}
	
	private def parameterName(extension TransformationContext context, MutableFieldDeclaration field) {
		val nameAnnotation = field.findAnnotation(typeof(Name).findTypeGlobally)
		return if (nameAnnotation == null) field.simpleName else nameAnnotation.getStringValue('value') 
	}
}