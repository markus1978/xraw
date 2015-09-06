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
		
						if (newTypeReference(List).isAssignableFrom(field.type)) {
							// array value
							return '''
								«toJavaCode(JSONArray.newTypeReference)» jsonArray = json.getJSONArray("«attributeName»");
								return «toJavaCode(field.type.actualTypeArguments.get(0))».createList(jsonArray);
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
									«val converterClass = context.withConverter(field)»
									«IF converterClass != null»
										Object objectValue = new «toJavaCode(converterClass)»().convert(json.getString("«attributeName»"));
									«ELSE»
										Object objectValue = json.get("«attributeName»");
										«IF field.type.type instanceof ClassDeclaration && (field.type.type as ClassDeclaration).findAnnotation(Response.findTypeGlobally) != null»
											objectValue = «toJavaCode(field.type)».create((«toJavaCode(JSONObject.newTypeReference)»)objectValue);
										«ENDIF»
									«ENDIF»
									if (objectValue instanceof «toJavaCode(field.type.wrapperIfPrimitive)») {
										return («toJavaCode(field.type.wrapperIfPrimitive)»)objectValue;
									} else {
										throw new «toJavaCode(ClassCastException.newTypeReference)»("Un expected type found in response.");
									}
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
}