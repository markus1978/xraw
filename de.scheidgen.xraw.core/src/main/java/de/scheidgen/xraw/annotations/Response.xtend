package de.scheidgen.xraw.annotations

import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONArray
import org.json.JSONObject
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext
import org.eclipse.xtend.lib.macro.declaration.TypeReference

@Active(typeof(ResponseCompilationParticipant))
annotation Response {

}

class ResponseCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {
	
	def withConverter(extension TransformationContext context, MutableFieldDeclaration field) {
		val converterAnnotation = field.findAnnotation(typeof(WithConverter).findTypeGlobally)
		return if (converterAnnotation == null) null else converterAnnotation.getClassValue("value") 
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
					return create(new «toJavaCode(JSONObject.newTypeReference)»(jsonStr));
				''']
			]
			
			clazz.addMethod("create") [
				static = true
				visibility = Visibility.PUBLIC
				addParameter("json", JSONObject.newTypeReference)
				returnType = newTypeReference(clazz)
				body = ['''
					return new «clazz.simpleName»(json);
				''']
			]
			
			clazz.addMethod("createList") [
				static = true
				visibility = Visibility.PUBLIC
				addParameter("jsonStr", string)
				returnType = newTypeReference(List, { newTypeReference(clazz) })
				body = ['''
					«toJavaCode(JSONArray.newTypeReference)» jsonArray = new «toJavaCode(JSONArray.newTypeReference)»(jsonStr);
					return createList(jsonArray);					
				''']
			]
			
			clazz.addMethod("createList") [
				static = true
				visibility = Visibility.PUBLIC
				addParameter("jsonArray", JSONArray.newTypeReference)
				returnType = newTypeReference(List, { newTypeReference(clazz) })
				body = ['''					
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

			for (field : declaredFields) {
				clazz.addMethod("get" + NameUtil::snakeCaseToCamelCase(field.simpleName).toFirstUpper) [
					docComment = field.docComment
					returnType = field.type
					body = [
						val attributeName = NameUtil::name(context, field)
						if (field.type.array) {
							// array value to array
							return '''
								«toJavaCode(JSONArray.newTypeReference)» jsonArray = json.getJSONArray("«attributeName»");
								«toJavaCode(field.type.arrayComponentType)»[] result = new «toJavaCode(field.type.arrayComponentType)»[jsonArray.length()];
								for (int i = 0; i < jsonArray.length(); i++) {
									«generateObjectValue(context, it, field, field.type.arrayComponentType, "jsonArray.getString(i)", "jsonArray.get(i)")»
									result[i] = value;
								}
								return result;
							'''
						} else if (newTypeReference(List).isAssignableFrom(field.type)) {
							// array value to list
							return '''
								«toJavaCode(field.type)» result = new «toJavaCode(ArrayList.newTypeReference(field.type.actualTypeArguments.get(0)))»();
								«toJavaCode(JSONArray.newTypeReference)» jsonArray = json.getJSONArray("«attributeName»");
								for (int i = 0; i < jsonArray.length(); i++) {
									«generateObjectValue(context, it, field, field.type.actualTypeArguments.get(0), "jsonArray.getString(i)", "jsonArray.get(i)")»
									result.add(value);
								}
								return result;
							'''
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
									«generateObjectValue(context, it, field, field.type, '''json.getString("«attributeName»")''', '''json.get("«attributeName»")''')»
									return value;
								}
							'''
						}
					]
				]
				field.docComment = null
				field.remove			
			}
			
			clazz.addMethod("toString") [
				addAnnotation(Override.newAnnotationReference)
				returnType = string
				body = ['''
					return json.toString();
				''']
			]				
		}
	}
	
	def generateObjectValue(extension TransformationContext transCtx, extension CompilationContext compCtx, MutableFieldDeclaration field, TypeReference type, String getString, String get) '''
		«toJavaCode(type.wrapperIfPrimitive)» value = null;
		«val converterClass = transCtx.withConverter(field)»
		«IF converterClass != null»
			Object objectValue = new «toJavaCode(converterClass)»().convert(«getString»);
		«ELSE»
			Object objectValue = «get»;
			«IF type.type instanceof ClassDeclaration && (type.type as ClassDeclaration).findAnnotation(Response.findTypeGlobally) != null»
				objectValue = «toJavaCode(type)».create((«toJavaCode(JSONObject.newTypeReference)»)objectValue);
			«ENDIF»
		«ENDIF»
		if (objectValue instanceof «toJavaCode(type.wrapperIfPrimitive)») {
			value = («toJavaCode(type.wrapperIfPrimitive)»)objectValue;
		} else {
			throw new «toJavaCode(ClassCastException.newTypeReference)»("Un expected type found in response.");
		}
	'''
}