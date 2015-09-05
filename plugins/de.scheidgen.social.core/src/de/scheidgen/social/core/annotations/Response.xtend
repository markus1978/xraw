package de.scheidgen.social.core.annotations

import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONObject
import org.json.JSONArray
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext

@Active(typeof(ResponseCompilationParticipant))
annotation Response {

}

annotation WithConverter {
	Class<? extends Converter<?>> value
}

interface Converter<T> {
	def T convert(String value)
}

class ResponseCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {
	
	def withConverter(extension TransformationContext context, MutableFieldDeclaration field) {
		val converterAnnotation = field.findAnnotation(typeof(WithConverter).findTypeGlobally)
		return if (converterAnnotation == null) null else converterAnnotation.getClassValue("value") 
	}
	
	def getValueJavaCode(extension CompilationContext compilationCtx, MutableFieldDeclaration field, extension TransformationContext transformationCtx) {
		val attributeName = NameUtil::name(transformationCtx, field)
		if (newTypeReference(List).isAssignableFrom(field.type)) {
			// array value
		} else {
			// single value
			return '''
				if (json.isNull("«attributeName»")) {
					«IF field.type.primitive»
						«IF field.initializer == null»
							throw new «toJavaCode(IllegalArgumentException.newTypeReference)»("null value not allowed for primitive type.");
						«ELSE»
							// empty
						«ENDIF»
					«ELSE»
						«field.simpleName» = null;
					«ENDIF»
				} else {
					«val converterClass = transformationCtx.withConverter(field)»
					«IF converterClass != null»
						Object objectValue = new «toJavaCode(converterClass)»().convert(json.getString("«attributeName»"));
					«ELSE»
						Object objectValue = json.get("«attributeName»");
					«ENDIF»
					if (objectValue instanceof «toJavaCode(field.type.wrapperIfPrimitive)») {
						«field.simpleName» = («toJavaCode(field.type.wrapperIfPrimitive)»)objectValue;
					} else {
						throw new «toJavaCode(ClassCastException.newTypeReference)»("Un expected type found in response.");
					}
				}
			'''
		}
	}
		

	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements,
			extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			val declaredFields = new ArrayList<MutableFieldDeclaration>
			declaredFields.addAll(clazz.declaredFields)
			
			clazz.addMethod("create") [
				static = true
				visibility = Visibility.PUBLIC
				addParameter("jsonStr", string)
				returnType = newTypeReference(clazz)
				body = '''
					«clazz.simpleName» result = new «clazz.simpleName»();
					result.parse(jsonStr);
					return result;
				'''
			]
			
			clazz.addMethod("createList") [
				static = true
				visibility = Visibility.PUBLIC
				addParameter("jsonStr", string)
				returnType = newTypeReference(List, { newTypeReference(clazz) })
				body = ['''
					«toJavaCode(JSONArray.newTypeReference)» jsonArray = new «toJavaCode(JSONArray.newTypeReference)»(jsonStr);
					«toJavaCode(List.newTypeReference({newTypeReference(clazz)}))» result = new «toJavaCode(ArrayList.newTypeReference({newTypeReference(clazz)}))»();
					for (int i = 0; i < jsonArray.length(); i++) {
						«toJavaCode(JSONObject.newTypeReference())» jsonObject = jsonArray.getJSONObject(i);
						«clazz.simpleName» value = new «clazz.simpleName»();
						value.fill(jsonObject);
						result.add(value);
					}
					return result;
				''']
			]
			
			clazz.addMethod("fill") [
				visibility = Visibility.PRIVATE
				addParameter("json", newTypeReference(JSONObject))
				body = ['''
					«FOR f: declaredFields»
						«getValueJavaCode(f, context)»
						
					«ENDFOR»
				''']
			]
					
			clazz.addMethod("parse") [
				visibility = Visibility.PRIVATE
				addParameter("jsonStr", string)
				body = ['''
					«toJavaCode(JSONObject.newTypeReference)» json = new «toJavaCode(JSONObject.newTypeReference)»(jsonStr);
					fill(json);
				''']
			]

			for (f : declaredFields) {
				f.visibility = Visibility.PRIVATE
				clazz.addMethod("get" + f.simpleName.toFirstUpper) [
					docComment = f.docComment
					returnType = f.type
					body = ['''
						return «f.simpleName»;
					''']
				]
				f.docComment = null				
			}			
		}
	}
}