package de.scheidgen.xraw.annotations

import de.scheidgen.xraw.DefaultResponse
import de.scheidgen.xraw.SocialService
import java.lang.annotation.Target
import java.util.ArrayList
import java.util.Collection
import java.util.Collections
import java.util.HashSet
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
import org.scribe.model.OAuthRequest
import org.scribe.model.Verb

@Active(typeof(RequestCompilationParticipant))
annotation Request {
	String url
	Response response
}

annotation Response {
	Class<? extends DefaultResponse> responseType = DefaultResponse
	Class<?> resourceType
	boolean isList = false
	String resourceKey = ""
}

@Target(FIELD) annotation Required {}
@Target(FIELD) annotation Post {}
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
			
			val responseAnnotation = clazz.findAnnotation(Request.findTypeGlobally).getAnnotationValue("response")
			
			clazz.addField("_service") [
				type = newTypeReference(SocialService)
				final = true
			]
			
			clazz.addField("_request") [
				type = newTypeReference(OAuthRequest)
				final = false
			]
			
			clazz.addField("_parameters") [
				type = Collection.newTypeReference(string)
				initializer = ['''new «toJavaCode(HashSet.newTypeReference(string))»()''']
				final = true
			]
			
			clazz.addField("_response") [
				type = responseAnnotation.getClassValue("responseType")
				initializer = '''null'''
				final = false
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
					val url = request.getValue('url') as String
				
					return '''
						this._service = service;
						this._request = new «toJavaCode(OAuthRequest.newTypeReference)»(«toJavaCode(Verb.newTypeReference)».GET, "«url»");
					'''
				]
			]
			
			clazz.addMethod("xResponse") [
				returnType = responseAnnotation.getClassValue("responseType")
				docComment = '''
					@return The {@link «responseAnnotation.getClassValue("responseType").simpleName»} instance that represents the response 
					to this request after it was executed. Executes this request implicitely.
				'''
				visibility = Visibility.PUBLIC
				body = [generateIfHasResponse(context, '''					
					return _response;
				''')]
			]
			
			val resultDocComment = '''
				@return The result of this request. Null if this request was not executed successfully. 
				Attempts to execute this request implicitely if it was not executed yet.
			'''
			if (responseAnnotation.getBooleanValue("isList")) {
				clazz.addMethod("xResults") [
					docComment = resultDocComment
					returnType = List.newTypeReference(responseAnnotation.getClassValue("resourceType"))
					visibility = Visibility.PUBLIC
					body = [generateIfHasResponse(context, '''
						«toJavaCode(JSONArray.newTypeReference)» jsonArray = _response.getJSONArray("«responseAnnotation.getStringValue("resourceKey")»");
						«toJavaCode(List.newTypeReference(responseAnnotation.getClassValue("resourceType")))» result = new «toJavaCode(ArrayList.newTypeReference(responseAnnotation.getClassValue("resourceType")))»(jsonArray.length());
						for (int i = 0; i < jsonArray.length(); i++) {
							result.add(new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»(jsonArray.getJSONObject(i)));
						}
						return «toJavaCode(Collections.newTypeReference())».unmodifiableList(result);
					''')]
				]
				clazz.addMethod("xResultAsArray") [
					docComment = resultDocComment
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
			} else {
				clazz.addMethod("xResult") [
					docComment = resultDocComment
					returnType = responseAnnotation.getClassValue("resourceType")
					body = [generateIfHasResponse(context, '''
						«toJavaCode(JSONObject.newTypeReference)» jsonObject = _response.getJSONObject("«responseAnnotation.getStringValue("resourceKey")»");					
						return new «toJavaCode(responseAnnotation.getClassValue("resourceType"))»(jsonObject);
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
							«val method = Verb.GET /* TODO when post*/»
							String url = _request.getUrl().replace("«urlReplaceAnnotation.getStringValue("value")»", «toJavaCode(string)».valueOf(«localName»));
							_request = new «toJavaCode(OAuthRequest.newTypeReference)»(«toJavaCode(Verb.newTypeReference)».«method.name», url);
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
							_request.addQuerystringParameter("«remoteName»", valueStr);
							_parameters.add("«remoteName»");
							return this;
						«ENDIF»
					'''] 
				]								
			}
			
			clazz.addMethod("xExecute") [
				returnType = clazz.newTypeReference
				visibility = Visibility.PUBLIC				
				
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
					«toJavaCode(org.scribe.model.Response.newTypeReference)» response = _service.send(_request);
					_response = new «toJavaCode(responseAnnotation.getClassValue("responseType"))»(response);
					return this;
				''']
			]
			
			for (field: declaredFields) {
				field.remove
			}
		}
	}

}