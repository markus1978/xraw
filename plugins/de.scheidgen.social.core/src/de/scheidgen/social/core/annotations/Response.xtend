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
	
	static def withConverter(extension TransformationContext context, MutableFieldDeclaration field) {
		val converterAnnotation = field.findAnnotation(typeof(WithConverter).findTypeGlobally)
		return if (converterAnnotation == null) null else converterAnnotation.getClassValue("value") 
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
						«val attributeName = NameUtil::name(context,f)»
						«val converterTypeRef = context.withConverter(f)»
						«IF converterTypeRef != null»
							«f.simpleName» = new «toJavaCode(converterTypeRef)»().convert(json.getString("«attributeName»"));
						«ELSEIF f.type == string»
							if (!json.isNull("«attributeName»")) {
								«f.simpleName» = json.getString("«attributeName»");
							}
						«ELSEIF f.type == primitiveBoolean || f.type == newTypeReference(Boolean)»
							if (json.isNull("«attributeName»")) {
								«IF f.type == primitiveBoolean»
									throw new «toJavaCode(IllegalArgumentException.newTypeReference)»("null value not allowed.");
								«ENDIF»
							} else {
								«f.simpleName» = json.getBoolean("«attributeName»");
							}
						«ELSEIF f.type == primitiveLong || f.type == newTypeReference(Long)»
							if (json.isNull("«attributeName»")) {
								«IF f.type == primitiveLong»
									throw new «toJavaCode(IllegalArgumentException.newTypeReference)»("null value not allowed.");
								«ENDIF»
							} else {
								«f.simpleName» = json.getLong("«attributeName»");
							}
						«ELSEIF f.type == primitiveInt || f.type == newTypeReference(Integer)»
							if (json.isNull("«attributeName»")) {
								«IF f.type == primitiveInt»
									throw new «toJavaCode(IllegalArgumentException.newTypeReference)»("null value not allowed.");
								«ENDIF»
							} else {
								«f.simpleName» = json.getInt("«attributeName»");
							}
						«ELSE»
							if (!json.isNull("«attributeName»")) {
								«f.simpleName» = («f.type.name»)json.get("«attributeName»");
							}
						«ENDIF»
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
					returnType = f.type
					body = ['''
						return «f.simpleName»;
					''']
				]				
			}

		}
	}
}