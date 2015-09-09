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
import org.eclipse.xtend.lib.macro.declaration.EnumerationTypeDeclaration
import de.scheidgen.xraw.AbstractResource

@Active(typeof(ResourceCompilationParticipant))
annotation Resource {

}

class ResourceCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {
	
	def withConverter(extension TransformationContext context, MutableFieldDeclaration field) {
		val converterAnnotation = field.findAnnotation(typeof(WithConverter).findTypeGlobally)
		return if (converterAnnotation == null) null else converterAnnotation.getClassValue("value") 
	}
	
	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements,
			extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			val declaredFields = new ArrayList<MutableFieldDeclaration>
			declaredFields.addAll(clazz.declaredFields)
			
			clazz.extendedClass = AbstractResource.newTypeReference

			clazz.addConstructor[
				visibility = Visibility.PUBLIC
				addParameter("json", newTypeReference(JSONObject))
				body = ['''
					super(json);
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
			Object objectValue = new «toJavaCode(converterClass)»().convert(«get».toString());
		«ELSE»
			Object objectValue = «get»;
			«IF type.type instanceof EnumerationTypeDeclaration»
				if (objectValue instanceof String) {
					objectValue = «toJavaCode(type)».valueOf((String)objectValue);
				} else {
					throw new «toJavaCode(ClassCastException.newTypeReference)»("Cannot create an enum value from a non string json value.");
				}
			«ELSEIF type.type instanceof ClassDeclaration && (type.type as ClassDeclaration).findAnnotation(Resource.findTypeGlobally) != null»
				objectValue = new «toJavaCode(type)»((«toJavaCode(JSONObject.newTypeReference)»)objectValue);
			«ENDIF»
		«ENDIF»
		if (objectValue instanceof «toJavaCode(type.wrapperIfPrimitive)») {
			value = («toJavaCode(type.wrapperIfPrimitive)»)objectValue;
		} else {
			throw new «toJavaCode(ClassCastException.newTypeReference)»("Un expected type found in response.");
		}
	'''
}