package de.scheidgen.xraw.annotations

import de.scheidgen.xraw.json.JSONArray
import de.scheidgen.xraw.json.JSONObject
import de.scheidgen.xraw.json.XObject
import de.scheidgen.xraw.server.XResource
import java.util.AbstractList
import java.util.AbstractMap
import java.util.AbstractSet
import java.util.ArrayList
import java.util.Iterator
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext
import org.eclipse.xtend.lib.macro.declaration.Element
import org.eclipse.xtend.lib.macro.declaration.EnumerationTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

interface TypeArgumentFactory<T> {
	def T create(JSONObject json, XObject container)
}

class JSONWrapperCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {

	def generatePutStatement(extension CompilationContext cmpCtx, extension TransformationContext tnsCtx,
			CharSequence sourceExpr, CharSequence keyExpr, CharSequence valueExpr, TypeReference valueTypeRef, Element source, ClassDeclaration classDeclaration) {
		val converterAnnotation = if (source instanceof FieldDeclaration) {
			source.findAnnotation(WithConverter.findTypeGlobally) 
		} 	
			
		if (converterAnnotation != null) {
			return '''
				«sourceExpr».put(«keyExpr», new «toJavaCode(converterAnnotation.getClassValue("value"))»().toString(«valueExpr»));
			'''
		} else if (valueTypeRef.wrapper) {
			val wrapper = valueTypeRef.wrapperIfPrimitive
			val cast = switch wrapper {
				case wrapper == Boolean.newTypeReference: "(boolean)"
				case wrapper == Long.newTypeReference: "(long)"
				case wrapper == Integer.newTypeReference: "(int)"
				case wrapper == Double.newTypeReference: "(double)"
				default: ""
			}
			if (cast == "") {
//				tnsCtx.addError(source, "Unsupported primitive type " + valueTypeRef.simpleName + ".")
			}
			return '''
				«sourceExpr».put(«keyExpr», «cast»«valueExpr»);
			'''		
		} else if (valueTypeRef.primitive) {
			return '''
				«sourceExpr».put(«keyExpr», «valueExpr»);
			'''	
		} else if (valueTypeRef == string) {
			return '''
				«sourceExpr».put(«keyExpr», «valueExpr»);
			'''
		} else if (valueTypeRef.type instanceof EnumerationTypeDeclaration) {
			return '''
				«sourceExpr».put(«keyExpr», «valueExpr».name());
			'''			
		} else if (JSONObject.newTypeReference.isAssignableFrom(valueTypeRef)) {
			return '''
				«sourceExpr».put(«keyExpr», «valueExpr»);
			'''
		} else {
			val valueType = valueTypeRef.type
			if (valueType instanceof ClassDeclaration) {
				if (valueType.findAnnotation(JSON.findTypeGlobally) != null) {
					return '''
						«sourceExpr».put(«keyExpr», «valueExpr».xJson());
						«valueExpr».xSetContainer(«classDeclaration.simpleName».this);
					'''
				} else {
//					tnsCtx.addError(source, "Object type " + valueTypeRef.simpleName + " is not a JSON type.")
					return '''
						throw new «toJavaCode(UnsupportedOperationException.newTypeReference)»("Object type «valueTypeRef.simpleName» is not a JSON type.");
					'''		
				}
			} else {
//				tnsCtx.addError(source, "Unsupported type " + valueTypeRef.simpleName + ".")
				return '''
					throw new «toJavaCode(UnsupportedOperationException.newTypeReference)»("Unsupported type «valueTypeRef.simpleName».");
				'''		
			}
		}
	}

	def generateAccessExpr(extension CompilationContext cmpCtx, extension TransformationContext tnsCtx,
			CharSequence sourceExpr, CharSequence keyExpr, TypeReference valueTypeRef, Element source, ClassDeclaration classDeclaration) {
		val converterAnnotation = if (source instanceof FieldDeclaration) {
			source.findAnnotation(WithConverter.findTypeGlobally) 
		} 	
			
		if (converterAnnotation != null) {
			return '''«sourceExpr».isNull(«keyExpr»)?null:new «toJavaCode(converterAnnotation.getClassValue("value"))»().toValue(«sourceExpr».get(«keyExpr»).toString())'''
		} else if (valueTypeRef.primitive || valueTypeRef.wrapper) {
			val wrapper = valueTypeRef.wrapperIfPrimitive
			val accessMethodName = switch wrapper {
				case wrapper == Boolean.newTypeReference: "getBoolean"
				case wrapper == Long.newTypeReference: "getLong"
				case wrapper == Integer.newTypeReference: "getInt"
				case wrapper == Double.newTypeReference: "getDouble"
				default: "get"
			}
			if (accessMethodName == "get") {
//				tnsCtx.addError(source, "Unsupported primitive type " + valueTypeRef.simpleName + ".")
			}

			if (valueTypeRef.wrapper) {
				val initExpr = if (source instanceof FieldDeclaration) {
					if (source.initializer != null) {
						source.initializer
					} else {
						"null"
					}
				} else {
					"null"
				}
				return '''«sourceExpr».isNull(«keyExpr»)?«initExpr»:«sourceExpr».«accessMethodName»(«keyExpr»)'''
			} else {
				val defaultExpr = switch wrapper {
					case wrapper == Boolean.newTypeReference: "false"
					case wrapper == Long.newTypeReference: "0l"
					case wrapper == Integer.newTypeReference: "0"
					case wrapper == Double.newTypeReference: "0.0"
					default: "null"
				}
				val initExpr = if (source instanceof FieldDeclaration) {
					if (source.initializer != null) {
						source.initializer
					} else {
						defaultExpr
					}
				} else {
					defaultExpr
				}
				return '''«sourceExpr».isNull(«keyExpr»)?«initExpr»:«sourceExpr».«accessMethodName»(«keyExpr»)'''
			}
		} else if (valueTypeRef == string) {
			return '''«sourceExpr».isNull(«keyExpr»)?null:«sourceExpr».getString(«keyExpr»)'''
		} else if (valueTypeRef.type instanceof EnumerationTypeDeclaration) {
			return '''«sourceExpr».isNull(«keyExpr»)?null:«toJavaCode(valueTypeRef)».valueOf(«sourceExpr».getString(«keyExpr»))'''
		} else if (JSONObject.newTypeReference.isAssignableFrom(valueTypeRef)) {
			return '''«sourceExpr».isNull(«keyExpr»)?null:«sourceExpr».getJSONObject(«keyExpr»)'''
		} else {
			val valueType = valueTypeRef.type
			if (valueType instanceof ClassDeclaration) {
				if (valueType.findAnnotation(JSON.findTypeGlobally) != null) {					
					if (valueType.typeParameters.empty) {
						return '''«sourceExpr».isNull(«keyExpr»)?null:new «toJavaCode(valueTypeRef)»(«sourceExpr».getJSONObject(«keyExpr»), «classDeclaration.simpleName».this)'''
					} else {
						return '''
							«sourceExpr».isNull(«keyExpr»)?null:new «toJavaCode(valueTypeRef)»(
								«sourceExpr».getJSONObject(«keyExpr»), «classDeclaration.simpleName».this,
								«generateTypeArguments(cmpCtx, tnsCtx, valueTypeRef)»
							)
						'''						
					}
				} else {
//					tnsCtx.addError(source, "Object type " + valueTypeRef.simpleName + " is not a JSON type.")
					return '''(«toJavaCode(valueTypeRef)»)«sourceExpr».get(«keyExpr»)'''		
				}
			} else if (valueType instanceof TypeParameterDeclaration) {
				if (valueType.upperBounds.exists[it.type instanceof ClassDeclaration && (it.type as ClassDeclaration).findAnnotation(JSON.findTypeGlobally) != null]) {
					return '''«sourceExpr».isNull(«keyExpr»)?null:«valueType.factoryFieldName».create(«sourceExpr».getJSONObject(«keyExpr»), «classDeclaration.simpleName».this)'''
				} else {
//				tnsCtx.addError(source, "Unsupported type " + valueTypeRef.simpleName + ".")
					return '''(«toJavaCode(valueTypeRef)»)«sourceExpr».get(«keyExpr») // unsupported type «valueTypeRef.simpleName»'''					
				}
				
			} else {
//				tnsCtx.addError(source, "Unsupported type " + valueTypeRef.simpleName + ".")			
				return '''«toJavaCode(valueTypeRef)»)«sourceExpr».get(«keyExpr»)'''
			}
		}
	}
	
	private def generateTypeArguments(extension CompilationContext cmpCtx, extension TransformationContext trnsCtx, TypeReference typeWithArguments) '''
		«FOR typeArgument:typeWithArguments.actualTypeArguments SEPARATOR ","»
			new «toJavaCode(TypeArgumentFactory.newTypeReference(typeArgument))»() {
				@Override
				public «toJavaCode(typeArgument)» create(«toJavaCode(JSONObject.newTypeReference)» json, «toJavaCode(XObject.newTypeReference)» container) {
					return new «toJavaCode(typeArgument)»(json, container);
				}
			}
		«ENDFOR»
	'''
	
	private def factoryFieldName(TypeParameterDeclaration typeParameter) {
		return "_" + typeParameter.simpleName.toFirstLower + "Factory"
	}
	
	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements,
			extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			val declaredFields = new ArrayList<MutableFieldDeclaration>
			declaredFields.addAll(clazz.declaredFields)
			
			if (clazz.extendedClass == null || clazz.extendedClass == Object.newTypeReference) {
				if (clazz.findAnnotation(Resource.findTypeGlobally) != null) {
					clazz.extendedClass = XResource.newTypeReference
				} else {
					clazz.extendedClass = XObject.newTypeReference					
				}				
			}
			
			for (typeParameter:clazz.typeParameters) {
			 	clazz.addField(typeParameter.factoryFieldName) [
			 		type = TypeArgumentFactory.newTypeReference(typeParameter.newTypeReference)
			 		final = true
			 	]
			}

			clazz.addConstructor[
				visibility = Visibility.PUBLIC
				addParameter("json", newTypeReference(JSONObject))
				addParameter("container", newTypeReference(XObject))
				for (typeParameter:clazz.typeParameters) {
					addParameter(typeParameter.factoryFieldName, TypeArgumentFactory.newTypeReference(typeParameter.newTypeReference))
				}
				body = ['''	
					«IF clazz.extendedClass.actualTypeArguments.empty»			
						super(json, container);
					«ELSE»
						super(json, container,
							«generateTypeArguments(context, clazz.extendedClass)»
						);
					«ENDIF»
					«FOR typeParameter:clazz.typeParameters»
						this.«typeParameter.factoryFieldName» = «typeParameter.factoryFieldName»;
					«ENDFOR»
				''']
			]
			
			clazz.addConstructor[
				visibility = Visibility.PUBLIC
				addParameter("json", newTypeReference(JSONObject))
				for (typeParameter:clazz.typeParameters) {
					addParameter(typeParameter.factoryFieldName, TypeArgumentFactory.newTypeReference(typeParameter.newTypeReference))
				}
				body = ['''	
					«IF clazz.extendedClass.actualTypeArguments.empty»			
						super(json);
					«ELSE»
						super(json,
							«generateTypeArguments(context, clazz.extendedClass)»
						);
					«ENDIF»
					«FOR typeParameter:clazz.typeParameters»
						this.«typeParameter.factoryFieldName» = «typeParameter.factoryFieldName»;
					«ENDFOR»
				''']
			]
			
			for (field : declaredFields) {
				clazz.addMethod("get" + NameUtil::snakeCaseToCamelCase(field.simpleName).toFirstUpper) [
					docComment = field.docComment
					returnType = field.type
					body = [
						val jsonName = NameUtil::name(context, field)
						if (List.newTypeReference.isAssignableFrom(field.type)) {
							val elementTypeRef = field.type.actualTypeArguments.get(0)
							val elementType = toJavaCode(elementTypeRef)
							'''
								if (json.isNull("«jsonName»")) {
									json.put("«jsonName»", json.xCreateNewArray());
									return get«NameUtil::snakeCaseToCamelCase(field.simpleName).toFirstUpper»();									
								} else {
									return new «toJavaCode(AbstractList.newTypeReference(field.type.actualTypeArguments))»() {
										@Override
										public «elementType» get(int index) {
											return «generateAccessExpr(context, '''json.getJSONArray("«jsonName»")''', "index", elementTypeRef, field, clazz)»;
										}
										
										@Override
										public int size() {
											return json.getJSONArray("«jsonName»").length();
										}
										
										@Override
										public void add(int index, «elementType» element) { 
											«generatePutStatement(context, '''json.getJSONArray("«jsonName»")''', "index", "element", elementTypeRef, field, clazz)»
										}
										
										@Override
										public «elementType» set(int index, «toJavaCode(field.type.actualTypeArguments.get(0))» element) {
											if (true)
												«generatePutStatement(context, '''json.getJSONArray("«jsonName»")''', "index", "element", elementTypeRef, field, clazz)»
											return element;											
										}
										
										@Override
										public «elementType» remove(int index) {
											«elementType» old = get(index);
											json.getJSONArray("«jsonName»").remove(index);
											return old;											
										}
									};
								}
							'''
						} else if (newTypeReference(Map).isAssignableFrom(field.type)) {
							if (field.type.actualTypeArguments.get(0) != string) {
//								addError(field, "Only string keys are allowed for maps.")
							}
							val elementTypeRef = field.type.actualTypeArguments.get(1)
							val elementType = toJavaCode(elementTypeRef)
							val entryTypeRef = Map.Entry.newTypeReference(string,elementTypeRef)
							val entryType = toJavaCode(entryTypeRef)
							'''
								if (json.isNull("«jsonName»")) {
									json.put("«jsonName»", json.xCreateNewObject());
									return get«NameUtil::snakeCaseToCamelCase(field.simpleName).toFirstUpper»();
								} else {
									return new «toJavaCode(AbstractMap.newTypeReference(string,elementTypeRef))»() {
										@Override
										public «toJavaCode(Set.newTypeReference(entryTypeRef))» entrySet() {
											return new «toJavaCode(AbstractSet.newTypeReference(entryTypeRef))»() {
												private final «toJavaCode(Iterator.newTypeReference(string))» sourceKeySetIt = json.getJSONObject("«jsonName»").keySet().iterator();
							    				@Override
							    				public «toJavaCode(Iterator.newTypeReference(entryTypeRef))» iterator() {
							    					return new «toJavaCode(Iterator.newTypeReference(entryTypeRef))»() {
														@Override
														public boolean hasNext() {
															return sourceKeySetIt.hasNext();
														}
							
														@Override
														public «toJavaCode(entryTypeRef)» next() {
															return new «entryType»() {
																private final «toJavaCode(string)» key = sourceKeySetIt.next();
																@Override
																public «toJavaCode(string)» getKey() {
																	return key;
																}
																
																@Override
																public «elementType» getValue() {
																	return «generateAccessExpr(context, '''json.getJSONObject("«jsonName»")''', "key", elementTypeRef, field, clazz)»;
																}
																
																@Override
																public «elementType» setValue(«elementType» value) {
																	«elementType» old = «generateAccessExpr(context, '''json.getJSONObject("«jsonName»")''', "key", elementTypeRef, field, clazz)»;
																	if (true) 
																		«generatePutStatement(context, '''json.getJSONObject("«jsonName»")''', "key", "value", elementTypeRef, field, clazz)»
																	return old;
																}
															};
														}
							
														@Override
														public void remove() {
															sourceKeySetIt.remove();
														}
													};
							    				}

												@Override
												public int size() {
													return json.getJSONObject("«jsonName»").length();
												}
											};
										}
										
										@Override
										public «toJavaCode(elementTypeRef)» put(«toJavaCode(string)» key,  «toJavaCode(elementTypeRef)» value) {
											«elementType» old = «generateAccessExpr(context, '''json.getJSONObject("«jsonName»")''', "key", elementTypeRef, field, clazz)»;
											if (true)
												«generatePutStatement(context, '''json.getJSONObject("«jsonName»")''', "key", "value", elementTypeRef, field, clazz)»
											return old;
										}
									};
								}
							'''
						} else {
							'''
								«IF (JSONObject.newTypeReference.isAssignableFrom(field.type))»
									if (json.isNull("«jsonName»")) {
										json.put("«jsonName»", new «toJavaCode(JSONObject.newTypeReference)»());
									}
								«ENDIF»
								return «generateAccessExpr(context, "json", '''"«jsonName»"''', field.type, field, clazz)»;
							'''	
						}					
					]					
				]
			}
			
			for (field : declaredFields) {						
				if (!field.type.array 
						&& !List.newTypeReference.isAssignableFrom(field.type) 
						&& !newTypeReference(Map).isAssignableFrom(field.type)) {
															
					clazz.addMethod("set" + NameUtil::snakeCaseToCamelCase(field.simpleName).toFirstUpper) [
						docComment = field.docComment
						addParameter("value", field.type)
						body = [
							val jsonName = NameUtil::name(context, field)
							return generatePutStatement(context, "json", '''"«jsonName»"''', "value", field.type, field, clazz)
						]					
					]
				}
			}			
			
			clazz.addMethod("toString") [
				addAnnotation(Override.newAnnotationReference)
				returnType = string
				body = ['''
					return json.toString();
				''']
			]
			
			for(field: declaredFields) {
				field.remove
			}				
		}
	}
}