package de.scheidgen.xraw.annotations

import de.scheidgen.xraw.AbstractRequest
import de.scheidgen.xraw.DefaultResponse
import de.scheidgen.xraw.SocialService
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.Collections
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONArray
import org.json.JSONObject
import org.scribe.model.Verb

@Active(typeof(RequestCompilationParticipant))
annotation Request {
	String url
	Response response
	Verb method = Verb.GET
}

annotation Response {
	Class<? extends DefaultResponse> responseType = DefaultResponse
	Class<?> resourceType
	boolean isList = false
	String resourceKey = ""
}

// TODO some form of "constraint language"
@Target(FIELD) annotation Required {}
@Target(TYPE) annotation OrConstraint { String[] value }
@Target(FIELD) annotation UrlReplace { String value }

class RequestCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {

	private def generateIfHasResponse(extension CompilationContext compilationContext, extension TransformationContext transformationContext, CharSequence code) '''
		if (_response == null) {
			xExecute();	
		}
		«code»
	'''

	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements,
			extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			val declaredFields = new ArrayList<MutableFieldDeclaration>
			declaredFields.addAll(clazz.declaredFields)
			
			val requestAnnotation = clazz.findAnnotation(Request.findTypeGlobally)
			val responseAnnotation = requestAnnotation.getAnnotationValue("response")
			val fullResourceType = if (responseAnnotation.getBooleanValue("isList")) {
				List.newTypeReference(responseAnnotation.getClassValue("resourceType"))
			} else {
				responseAnnotation.getClassValue("resourceType")
			}
			clazz.extendedClass = AbstractRequest.newTypeReference(responseAnnotation.getClassValue("responseType"), fullResourceType)
			
			clazz.addMethod("create") [
				static = true
				addParameter("service", newTypeReference(SocialService))
				returnType = clazz.newTypeReference
				body = ['''
					return new «toJavaCode(clazz.newTypeReference)»(service);
				''']
			]
			
			clazz.addMethod("createResponse") [
				visibility = Visibility.PROTECTED
				addAnnotation(Override.newAnnotationReference)
				addParameter("scribeResponse", org.scribe.model.Response.newTypeReference)
				val responseType = responseAnnotation.getClassValue("responseType")
				returnType = responseType
				body = ['''
					return new «toJavaCode(responseType)»(scribeResponse);
				''']
			]
			
			clazz.addMethod("validateConstraints") [
				visibility = Visibility.PROTECTED
				addAnnotation(Override.newAnnotationReference)
				body = ['''
					«FOR fieldWithRequiredAnnoation: declaredFields.filter[findAnnotation(Required.findTypeGlobally) != null]»
						if (!xIsSetQueryStringParameter("«NameUtil::name(context, fieldWithRequiredAnnoation)»")) {
							throw new «toJavaCode(IllegalArgumentException.newTypeReference)»("The parameter «fieldWithRequiredAnnoation.simpleName» is required.");
						}
					«ENDFOR»
					«val orConstraintAnnoation = clazz.findAnnotation(OrConstraint.findTypeGlobally)»
					«IF orConstraintAnnoation != null»
						boolean orConstraintFulfilled = false;
						«FOR parameterName: orConstraintAnnoation.getStringArrayValue("value")»
							orConstraintFulfilled |= xIsSetQueryStringParameter("«parameterName»");
						«ENDFOR»
						if (!orConstraintFulfilled) {
							throw new «toJavaCode(IllegalArgumentException.newTypeReference)»("At least one of the parameters «orConstraintAnnoation.getStringArrayValue("value").arrayToString»  has tobe set.");
						}
					«ENDIF»
				''']
			]
			
			clazz.addConstructor [
				visibility = Visibility.PROTECTED
				addParameter("service", newTypeReference(SocialService))
				val url = requestAnnotation.getStringValue("url") 
				val method = requestAnnotation.getEnumValue("method")
				body = ['''
					super(service, «toJavaCode(Verb.newTypeReference)».«method.simpleName», "«url»");
				''']
			]
			
			clazz.addMethod("xResult") [
				visibility = Visibility.PUBLIC
				addAnnotation(Override.newAnnotationReference)
				returnType = fullResourceType
				if (responseAnnotation.getBooleanValue("isList")) {
					body = [generateIfHasResponse(context, '''
						«toJavaCode(JSONArray.newTypeReference)» jsonArray = _response.getJSONArray("«responseAnnotation.getStringValue("resourceKey")»");
						«toJavaCode(List.newTypeReference(responseAnnotation.getClassValue("resourceType")))» result = new «toJavaCode(ArrayList.newTypeReference(responseAnnotation.getClassValue("resourceType")))»(jsonArray.length());
						for (int i = 0; i < jsonArray.length(); i++) {
							result.add(new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»(jsonArray.getJSONObject(i)));
						}
						return «toJavaCode(Collections.newTypeReference())».unmodifiableList(result);
					''')]					
				} else {
					body = [generateIfHasResponse(context, '''
						«toJavaCode(JSONObject.newTypeReference)» jsonObject = _response.getJSONObject("«responseAnnotation.getStringValue("resourceKey")»");					
						return new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»(jsonObject);
					''')]
				}
			]
			
			if (responseAnnotation.getBooleanValue("isList")) {				
				clazz.addMethod("xResultAsArray") [
					docComment = '''
						@return The result of this request. Null if this request was not executed successfully. 
						Attempts to execute this request implicitely if it was not executed yet.
					'''
					returnType = responseAnnotation.getClassValue("resourceType").newArrayTypeReference
					body = [generateIfHasResponse(context, '''					
						«toJavaCode(JSONArray.newTypeReference)» jsonArray = _response.getJSONArray("«responseAnnotation.getStringValue("resourceKey")»");
						«toJavaCode(responseAnnotation.getClassValue("resourceType").newArrayTypeReference)» result = new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»[jsonArray.length()];
						for (int i = 0; i < jsonArray.length(); i++) {
							result[i] = new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»(jsonArray.getJSONObject(i));
						}
						return result;
					''')]
				]
			}
			
			for (field : declaredFields) {
				val localName = NameUtil::snakeCaseToCamelCase(field.simpleName)
				clazz.addMethod(localName) [
					visibility = Visibility.PUBLIC
					addParameter(localName, field.type)
					docComment = field.docComment
					returnType = clazz.newTypeReference
					val remoteName = NameUtil::name(context, field)
					body = ['''
						if (_response != null) {
							throw new «toJavaCode(IllegalStateException.newTypeReference)»("This request was already executed. Its parameters cannot be changed anymore.");
						}
						«val urlReplaceAnnotation = field.findAnnotation(UrlReplace.findTypeGlobally)»
						«IF (urlReplaceAnnotation != null)»					
							String url = xGetUrl().replace("«urlReplaceAnnotation.getStringValue("value")»", «toJavaCode(string)».valueOf(«localName»));
							xSetUrl(url);
							return this; 
						«ELSE»
							String valueStr = null;
							«IF List.newTypeReference.isAssignableFrom(field.type)»
								valueStr = "";
								boolean first = true;
								for («toJavaCode(field.type.actualTypeArguments.get(0))» value: «localName») {
									if (first) {
										first = false;
									} else {
										valueStr += ", ";
									}
									valueStr += «toJavaCode(string)».valueOf(value);
								}
							«ELSE»
								valueStr = «toJavaCode(string)».valueOf(«localName»);								
							«ENDIF»
							xPutQueryStringParameter("«remoteName»", valueStr);
							return this;
						«ENDIF»
					'''] 
				]								
			}
			
			clazz.addMethod("xExecute") [
				visibility = Visibility.PUBLIC
				addAnnotation(Override.newAnnotationReference)
				returnType = clazz.newTypeReference
				body = ['''
					return («toJavaCode(clazz.newTypeReference)»)super.xExecute();
				''']
			]
			
			for (field: declaredFields) {
				field.remove
			}
		}
	}

	def arrayToString(String[] array) '''«FOR value:array SEPARATOR ","»«value»«ENDFOR»'''
}