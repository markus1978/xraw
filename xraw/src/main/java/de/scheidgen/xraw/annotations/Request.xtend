package de.scheidgen.xraw.annotations

import com.mashape.unirest.http.HttpMethod
import de.scheidgen.xraw.client.json.JSONArray
import de.scheidgen.xraw.client.json.JSONObject
import de.scheidgen.xraw.client.json.XObject
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
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import de.scheidgen.xraw.client.core.DefaultResponse
import de.scheidgen.xraw.client.core.AbstractRequest
import de.scheidgen.xraw.client.core.XRawHttpService
import de.scheidgen.xraw.client.core.XRawHttpMethod
import de.scheidgen.xraw.client.core.XRawHttpResponse

@Active(typeof(RequestCompilationParticipant))
annotation Request {
	String url
	Response response
	HttpMethod method = HttpMethod.GET
	Parameter[] parameters = #[]
}

annotation Parameter {
	String name
	String value
}

annotation Response {
	Class<? extends DefaultResponse> responseType = DefaultResponse
	Class<?> resourceType
	boolean isList = false
	String resourceKey = ""
}

// TODO some form of "constraint language"
@Target(FIELD) annotation Required {}
@Target(FIELD) annotation Body {}
@Target(TYPE) annotation OrConstraint { String[] value }
@Target(TYPE) annotation XorOrNothingConstraint { String[] value }
@Target(FIELD) annotation UrlReplace { String value }

/**
 * Allows for list parameters to create queries with multiple parameter of same name for each elements.
 * Although, this it not supported by Xraws XrawHttpRequest implementation, which only supports unique parameter names yet.
 */
@Target(FIELD) annotation Multi {}

class RequestCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {

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
			
			clazz.addConstructor[
				addParameter("service", newTypeReference(XRawHttpService))
				val url = requestAnnotation.getStringValue("url") 
				val method = requestAnnotation.getEnumValue("method")
				body = ['''
					super(service, service.createEmptyRequest(«toJavaCode(XRawHttpMethod.newTypeReference)».«method.simpleName», "«url»"));
					«FOR field:declaredFields.filter[it.initializer != null]»
						«val localName = NameUtil::snakeCaseToCamelCase(field.simpleName)»
						«localName»(«field.initializer»);
					«ENDFOR»
					«FOR parameterAnnotation:requestAnnotation.getAnnotationArrayValue("parameters")»
						xPutQueryStringParameter("«parameterAnnotation.getStringValue("name")»", "«parameterAnnotation.getStringValue("value")»");
					«ENDFOR»
				''']
			]
			
			clazz.addMethod("createResponse") [
				visibility = Visibility.PROTECTED
				addAnnotation(Override.newAnnotationReference)
				addParameter("httpResponse", XRawHttpResponse.newTypeReference)
				val responseType = responseAnnotation.getClassValue("responseType")
				returnType = responseType
				body = ['''
					return new «toJavaCode(responseType)»(httpResponse);
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
					«val xorOrNothingConstraintAnnoation = clazz.findAnnotation(XorOrNothingConstraint.findTypeGlobally)»
					«IF xorOrNothingConstraintAnnoation != null»
						int xorOrNothingConstraintParamsSet = 0;
						«FOR parameterName: xorOrNothingConstraintAnnoation.getStringArrayValue("value")»
							if (xIsSetQueryStringParameter("«parameterName»")) {
								xorOrNothingConstraintParamsSet += 1;
							}
						«ENDFOR»
						if (xorOrNothingConstraintParamsSet > 1) {
							throw new «toJavaCode(IllegalArgumentException.newTypeReference)»("One one or none of the parameters «xorOrNothingConstraintAnnoation.getStringArrayValue("value").arrayToString»  must be set.");
						}
					«ENDIF»
				''']
			]
			
			clazz.addMethod("xResult") [
				visibility = Visibility.PUBLIC
				addAnnotation(Override.newAnnotationReference)
				returnType = fullResourceType
				val jsonAccessMethod = if (responseAnnotation.getBooleanValue("isList")) "getJSONArray" else "getJSONObject"
				val resourceKey = responseAnnotation.getStringValue("resourceKey")
				val resourceKeyFragments = resourceKey.split("\\.")
				val jsonAccessExpr = if (resourceKey == "") {
					'''xResponse().«jsonAccessMethod»("")'''
				} else {
					'''xResponse().«IF resourceKeyFragments.size > 1»«FOR i:0..(resourceKeyFragments.size-2) SEPARATOR "."»getJSONObject("«resourceKeyFragments.get(i)»")«ENDFOR».«ENDIF»«jsonAccessMethod»("«resourceKeyFragments.last»")'''
				}
				if (responseAnnotation.getBooleanValue("isList")) {
					body = ['''
						«toJavaCode(JSONArray.newTypeReference)» jsonArray = «jsonAccessExpr»;
						«toJavaCode(List.newTypeReference(responseAnnotation.getClassValue("resourceType")))» result = new «toJavaCode(ArrayList.newTypeReference(responseAnnotation.getClassValue("resourceType")))»(jsonArray.length());
						for (int i = 0; i < jsonArray.length(); i++) {
							result.add(new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»(jsonArray.getJSONObject(i)));
						}
						return «toJavaCode(Collections.newTypeReference())».unmodifiableList(result);
					''']					
				} else {
					body = ['''
						«toJavaCode(JSONObject.newTypeReference)» jsonObject = «jsonAccessExpr»;
						return new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»(jsonObject);
					''']
				}
			]
			
			if (responseAnnotation.getBooleanValue("isList")) {				
				clazz.addMethod("xResultAsArray") [
					docComment = '''
						@return The result of this request. Null if this request was not executed successfully. 
						Attempts to execute this request implicitely if it was not executed yet.
					'''
					returnType = responseAnnotation.getClassValue("resourceType").newArrayTypeReference
					body = ['''					
						«toJavaCode(JSONArray.newTypeReference)» jsonArray = xResponse().getJSONArray("«responseAnnotation.getStringValue("resourceKey")»");
						«toJavaCode(responseAnnotation.getClassValue("resourceType").newArrayTypeReference)» result = new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»[jsonArray.length()];
						for (int i = 0; i < jsonArray.length(); i++) {
							result[i] = new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»(jsonArray.getJSONObject(i));
						}
						return result;
					''']
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
					val isListType = List.newTypeReference.isAssignableFrom(field.type)
					val isBody = field.findAnnotation(Body.findTypeGlobally) != null
					body = ['''
						if (xIsExecuted()) {
							throw new «toJavaCode(IllegalStateException.newTypeReference)»("This request was already executed. Its parameters cannot be changed anymore.");
						}
						«val urlReplaceAnnotation = field.findAnnotation(UrlReplace.findTypeGlobally)»
						«IF (urlReplaceAnnotation != null)»					
							String url = xGetUrl().replace("«urlReplaceAnnotation.getStringValue("value")»", «toJavaCode(string)».valueOf(«localName»));
							xSetUrl(url);							
						«ELSEIF (field.findAnnotation(Multi.findTypeGlobally) != null && isListType)»
							for («toJavaCode(field.type.actualTypeArguments.get(0))» value: «localName») {
								String valueStr = «toJavaCode(string)».valueOf(value);
								xPutQueryStringParameter("«remoteName»", valueStr);
							}
						«ELSE»
							String valueStr = null;
							«IF isListType»
								valueStr = "";
								boolean first = true;
								for («toJavaCode(field.type.actualTypeArguments.get(0))» value: «localName») {
									if (first) {
										first = false;
									} else {
										valueStr += ", ";
									}
									valueStr += «generateToString(it, context, field.type, "value")»;
								}
							«ELSE»
								valueStr = «generateToString(it, context, field.type, localName)»;
							«ENDIF»
							«IF isBody»
								xPutBody(valueStr);
							«ELSE»
								xPutQueryStringParameter("«remoteName»", valueStr);
							«ENDIF»							
						«ENDIF»
						return this;
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
	
	def generateToString(extension CompilationContext cc, extension TransformationContext tc, TypeReference type, String valueAccessStr) {
		if (XObject.newTypeReference.isAssignableFrom(type)) {
			'''«valueAccessStr».xJson().xNative().toString()'''
		} else {
			'''«toJavaCode(string)».valueOf(«valueAccessStr»)'''
		}
	}

	def arrayToString(String[] array) '''«FOR value:array SEPARATOR ","»«value»«ENDFOR»'''
}