package de.scheidgen.social.core.annotations

import java.util.ArrayList
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
	
	def snakeCaseToCamelCase(String source) {
		val parts = source.split("_")
		val target = parts.join("") [
			it.toFirstUpper
		]
		return if (source.equals(source.toFirstLower)) target.toFirstLower else target
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
							return «field.initializer»;
						«ENDIF»
					«ELSE»
						return null;
					«ENDIF»
				} else {
					«val converterClass = transformationCtx.withConverter(field)»
					«IF converterClass != null»
						Object objectValue = new «toJavaCode(converterClass)»().convert(json.getString("«attributeName»"));
					«ELSE»
						Object objectValue = json.get("«attributeName»");
					«ENDIF»
					if (objectValue instanceof «toJavaCode(field.type.wrapperIfPrimitive)») {
						return («toJavaCode(field.type.wrapperIfPrimitive)»)objectValue;
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
			
			clazz.addField("json") [
				type = newTypeReference(JSONObject)
				visibility = Visibility.PRIVATE 
			]
			
			clazz.addMethod("create") [
				static = true
				visibility = Visibility.PUBLIC
				addParameter("jsonStr", string)
				returnType = newTypeReference(clazz)
				body = ['''
					return new «clazz.simpleName»(new «toJavaCode(JSONObject.newTypeReference)»(jsonStr));
				''']
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
						result.add(new «clazz.simpleName»(jsonArray.getJSONObject(i)));
					}
					return result;
				''']
			]
			
			clazz.addConstructor[
				visibility = Visibility.PRIVATE
				addParameter("json", newTypeReference(JSONObject))
				body = ['''
					this.json = json;
				''']
			]

			for (f : declaredFields) {
				f.visibility = Visibility.PRIVATE
				clazz.addMethod("get" + f.simpleName.snakeCaseToCamelCase.toFirstUpper) [
					docComment = f.docComment
					returnType = f.type
					body = [getValueJavaCode(f, context)]
				]
				f.docComment = null
				f.remove			
			}				
		}
	}
}