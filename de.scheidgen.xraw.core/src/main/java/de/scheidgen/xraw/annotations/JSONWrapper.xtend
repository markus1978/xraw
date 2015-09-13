package de.scheidgen.xraw.annotations

import com.google.common.collect.AbstractIterator
import java.util.AbstractList
import java.util.AbstractMap
import java.util.AbstractSet
import java.util.ArrayList
import java.util.Iterator
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext
import org.eclipse.xtend.lib.macro.declaration.Element
import org.eclipse.xtend.lib.macro.declaration.EnumerationTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.json.JSONObject
import de.scheidgen.xraw.AbstractJSONWrapper

@Active(typeof(JSONWrapperCompilationParticipant))
annotation JSON {

}

class JSONWrapperCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {

	def generateAccessExpr(extension CompilationContext cmpCtx, extension TransformationContext tnsCtx,
			CharSequence sourceExpr, CharSequence keyExpr, TypeReference valueTypeRef, Element source) {
		val converterAnnotation = if (source instanceof FieldDeclaration) {
			source.findAnnotation(WithConverter.findTypeGlobally) 
		} 	
			
		if (converterAnnotation != null) {
			return '''«sourceExpr».isNull(«keyExpr»)?null:new «toJavaCode(converterAnnotation.getClassValue("value"))»().convert(«sourceExpr».getString(«keyExpr»))'''
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
				tnsCtx.addError(source, "Unsupported primitive type " + valueTypeRef.simpleName + ".")
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
					return '''«sourceExpr».isNull(«keyExpr»)?null:new «toJavaCode(valueTypeRef)»(«sourceExpr».getJSONObject(«keyExpr»))'''
				} else {
					tnsCtx.addError(source, "Object type " + valueTypeRef.simpleName + " is not a JSON type.")
					return '''(«toJavaCode(valueTypeRef)»)«sourceExpr».get(«keyExpr»)'''		
				}
			} else {
				tnsCtx.addError(source, "Unsupported type " + valueTypeRef.simpleName + ".")
				return '''(«toJavaCode(valueTypeRef)»)«sourceExpr».get(«keyExpr»)'''
			}
		}
	}
	
	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements,
			extension TransformationContext context) {
		for (clazz : annotatedTargetElements) {
			val declaredFields = new ArrayList<MutableFieldDeclaration>
			declaredFields.addAll(clazz.declaredFields)
			
			clazz.extendedClass = AbstractJSONWrapper.newTypeReference

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
						val jsonName = NameUtil::name(context, field)
						if (field.type.array) {
							addError(field, "Arrays are not supported")
							'''
								return null;
							'''
						} else if (List.newTypeReference.isAssignableFrom(field.type)) {
							val elementType = toJavaCode(field.type.actualTypeArguments.get(0))
							'''
								if (json.isNull("«jsonName»")) {
									return null;
								} else {
									return new «toJavaCode(AbstractList.newTypeReference(field.type.actualTypeArguments))»() {
										@Override
										public «elementType» get(int index) {
											return «generateAccessExpr(context, '''json.getJSONArray("«jsonName»")''', "index", field.type.actualTypeArguments.get(0), field)»;
										}
										
										@Override
										public int size() {
											return json.getJSONArray("«jsonName»").length();
										}
										
										@Override
										public void add(int index, «elementType» element) {
											throw new UnsupportedOperationException("Mutable arrays not supported yet");
										}
										
										@Override
										public «elementType» set(int index, «toJavaCode(field.type.actualTypeArguments.get(0))» element) {
											throw new UnsupportedOperationException("Mutable arrays not supported yet");
										}
										
										@Override
										public «elementType» remove(int index) {
											throw new UnsupportedOperationException("Mutable arrays not supported yet");
										}
									};
								}
							'''
						} else if (newTypeReference(Map).isAssignableFrom(field.type)) {
							if (field.type.actualTypeArguments.get(0) != string) {
								addError(field, "Only string keys are allowed for maps.")
							}
							val elementTypeRef = field.type.actualTypeArguments.get(1)
							val elementType = toJavaCode(elementTypeRef)
							val entryTypeRef = Map.Entry.newTypeReference(string,elementTypeRef)
							val entryType = toJavaCode(entryTypeRef)
							'''
								if (json.isNull("«jsonName»")) {
									return null;
								} else {
									return new «toJavaCode(AbstractMap.newTypeReference(string,elementTypeRef))»() {
										@Override
										public «toJavaCode(Set.newTypeReference(entryTypeRef))» entrySet() {
											return new «toJavaCode(AbstractSet.newTypeReference(entryTypeRef))»() {
												private final «toJavaCode(JSONObject.newTypeReference)» source = json.getJSONObject("«jsonName»");
												@Override
												public «toJavaCode(Iterator.newTypeReference(entryTypeRef))» iterator() {
													return new «toJavaCode(AbstractIterator.newTypeReference(entryTypeRef))»() {
														private «toJavaCode(Iterator.newTypeReference(string))» sourceKeys = json.getJSONObject("«jsonName»").keys();
														@Override
														protected «entryType» computeNext() {
															if (sourceKeys.hasNext()) {
																return new «entryType»() {
																	private final «toJavaCode(string)» key = sourceKeys.next();
																	@Override
																	public «toJavaCode(string)» getKey() {
																		return key;
																	}
																	
																	@Override
																	public «elementType» getValue() {
																		return «generateAccessExpr(context, "source", "key", elementTypeRef, field)»;
																	}
																	
																	@Override
																	public «elementType» setValue(«elementType» value) {
																		throw new UnsupportedOperationException("Mutable maps are not supported.");
																	}
																};
															} else {
																return endOfData();
															}
														}
													};
												}
												
												@Override
												public int size() {
													return source.length();
												}
											};
										}
									};
								}
							'''
						} else {
							'''
								return «generateAccessExpr(context, "json", '''"«jsonName»"''', field.type, field)»;
							'''	
						}					
					]					
				]
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