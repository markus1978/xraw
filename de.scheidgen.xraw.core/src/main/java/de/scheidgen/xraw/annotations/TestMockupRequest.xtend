package de.scheidgen.xraw.annotations

import de.scheidgen.xraw.core.AbstractTestMockupRequest
import de.scheidgen.xraw.core.XRawHttpMethod
import de.scheidgen.xraw.core.XRawHttpRequest
import java.util.ArrayList
import java.util.List
import java.util.Map
import java.util.regex.Pattern
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import de.scheidgen.xraw.json.XObject

/**
 * Generates a abstract test mockup that can be extended by clients to easily write API mockups for tests.
 * Comes with limitations: Only one url replacement parameter and value is allowed. Url replacement values
 * can only be consist of Alnums and must not be empty.
 */
@Active(typeof(TestMockupRequestCompilationParticipant))
annotation TestMockupRequest {}

class TestMockupRequestCompilationParticipant extends AbstractClassProcessor {
	
	val Map<String, List<? extends FieldDeclaration>> allDeclaredFields = newHashMap
	
	public static def createdClassName(ClassDeclaration annotatedClass) {
		annotatedClass.qualifiedName + "Mockup"
	}
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		super.doRegisterGlobals(annotatedClass, context)
		context.registerClass(annotatedClass.createdClassName)
		
		val List<FieldDeclaration> declaredFields = new ArrayList<FieldDeclaration>
		for(field:annotatedClass.declaredFields) {
			declaredFields.add(field)
		}
		allDeclaredFields.put(annotatedClass.createdClassName, declaredFields)
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		super.doTransform(annotatedClass, context)
		val clazz = context.findClass(annotatedClass.createdClassName)

		val declaredFields = allDeclaredFields.get(annotatedClass.createdClassName)
		
		val requestAnnotation = annotatedClass.findAnnotation(Request.findTypeGlobally)
		val responseAnnotation = requestAnnotation.getAnnotationValue("response")
		val fullResourceType = if (responseAnnotation.getBooleanValue("isList")) {
			List.newTypeReference(responseAnnotation.getClassValue("resourceType"))
		} else {
			responseAnnotation.getClassValue("resourceType")
		} 
		
		clazz.abstract = true
		
		clazz.extendedClass = AbstractTestMockupRequest.newTypeReference(fullResourceType)
		
		clazz.addMethod("xMatches") [
			addParameter("httpRequest", XRawHttpRequest.newTypeReference)
			returnType = primitiveBoolean
			visibility = Visibility.PUBLIC
			addAnnotation(Override.newAnnotationReference)
			val url = requestAnnotation.getStringValue("url") 
			val method = requestAnnotation.getEnumValue("method")
			body = ['''
				return "«url»".equals(httpRequest.getUrl()) && «toJavaCode(XRawHttpMethod.newTypeReference)».«method.simpleName» == httpRequest.getMethod();
			''']
		]		
	
		for (field : declaredFields) {
			val localName = NameUtil::snakeCaseToCamelCase(field.simpleName)
			clazz.addMethod(localName) [
				visibility = Visibility.PUBLIC
				returnType = mockupType(context, field.type)
				docComment = field.docComment
				addParameter("httpRequest", XRawHttpRequest.newTypeReference)
				val remoteName = NameUtil::name(context, field)
				val url = requestAnnotation.getStringValue("url")
				val isListType = List.newTypeReference.isAssignableFrom(field.type) 
				body = ['''
					«val urlReplaceAnnotation = field.findAnnotation(UrlReplace.findTypeGlobally)»
					«IF (urlReplaceAnnotation != null)»						
						String url = "«url»".replace("«urlReplaceAnnotation.getStringValue("value")»", "%%%");
						String quotedUrl = «toJavaCode(Pattern.newTypeReference)».quote(url);
						String pattern = quotedUrl.replace("%%%", "(\\p{Alnum}+)");
						String strValue = «toJavaCode(Pattern.newTypeReference)».compile(pattern).matcher(httpRequest.getUrl()).group(1);
						return «generateToString(it, context, field.type, "strValue")»;
					«ELSEIF (field.findAnnotation(Multi.findTypeGlobally) != null && isListType)»
						
					«ELSE»
						«IF field.findAnnotation(Body.findTypeGlobally) != null»
							String valueStr = (String)httpRequest.getBody();
						«ELSE»
							String valueStr = (String)httpRequest.getQueryString().get("«remoteName»");
						«ENDIF»						
						«IF isListType»
							«toJavaCode(ArrayList.newTypeReference(field.type.actualTypeArguments.get(0)))» result = new «toJavaCode(ArrayList.newTypeReference(field.type.actualTypeArguments.get(0)))»();
							if (valueStr == null) {
								return result;
							} else {
								String[] values = valueStr.split(",");
								for(String value: values) {
									result.add(«generateToString(it, context, field.type.actualTypeArguments.get(0), "value.trim()")»);
								}
							}
							return result;
						«ELSE»
							return «generateToString(it, context, field.type, "valueStr")»;
						«ENDIF»							
					«ENDIF»
				'''] 
			]								
		}
	}
	
	def TypeReference mockupType(extension TransformationContext ctx, TypeReference type) {
		if (XObject.newTypeReference.isAssignableFrom(type)) {
			string // we use the string (json) representation of the values
		} else {
			return type
		}
	}
	
	def generateToString(extension CompilationContext compCtx, extension TransformationContext ctx, TypeReference type, String stringValueRef) {
		if (type.primitive) {
			return '''«toJavaCode(type.wrapperIfPrimitive)».valueOf(«stringValueRef»)'''
		} else if (type.wrapper) {
			return '''«toJavaCode(type)».valueOf(«stringValueRef»)'''
		} else if (type == String.newTypeReference) {
			return '''«stringValueRef»'''
		} else if (XObject.newTypeReference.isAssignableFrom(type)) {
			return '''«stringValueRef»''' // we use the string (json) representation of the values
		} else {
			throw new IllegalArgumentException('''Parameter type «type» is not supported.''')
		}
	}

	def arrayToString(String[] array) '''«FOR value:array SEPARATOR ","»«value»«ENDFOR»'''
}