package de.scheidgen.xraw.annotations

import com.mashape.unirest.http.HttpMethod
import de.scheidgen.xraw.AbstractRequest
import de.scheidgen.xraw.DefaultResponse
import de.scheidgen.xraw.http.XRawHttpResponse
import de.scheidgen.xraw.http.XRawHttpService
import de.scheidgen.xraw.json.NameUtil
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.Collections
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONArray
import org.json.JSONObject

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
@Target(TYPE) annotation OrConstraint { String[] value }
@Target(TYPE) annotation XorOrNothingConstraint { String[] value }
@Target(FIELD) annotation UrlReplace { String value }

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
					super(service, «toJavaCode(HttpMethod.newTypeReference)».«method.simpleName», "«url»");
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
					'''xResponse().«FOR i:0..(resourceKeyFragments.size-2) SEPARATOR "."»getJSONObject("«resourceKeyFragments.get(i)»")«ENDFOR».«jsonAccessMethod»("«resourceKeyFragments.last»")'''
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
					body = ['''
						if (xIsExecuted()) {
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