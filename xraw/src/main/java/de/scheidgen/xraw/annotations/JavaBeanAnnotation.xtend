package de.scheidgen.xraw.annotations

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.Active
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import java.util.List
import java.util.ArrayList

@Active(JavaBeanAnnotationClassProcessor)
@Target(TYPE)
annotation JavaBean {
	
}

@Target(FIELD)
annotation Hidden {
	
}

class JavaBeanAnnotationClassProcessor extends AbstractClassProcessor {
	
	public static def createdClassName(ClassDeclaration annotatedClass) {
		annotatedClass.qualifiedName + "Bean"
	}
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		super.doRegisterGlobals(annotatedClass, context)
		context.registerClass(annotatedClass.createdClassName)
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		super.doTransform(annotatedClass, context)
		val beanClass = context.findClass(annotatedClass.createdClassName)
		
		for(field: annotatedClass.declaredFields) {
			val hidden = field.findAnnotation(Hidden.findTypeGlobally) != null
			val camelCaseFieldName = NameUtil.snakeCaseToCamelCase(field.simpleName)
			val fieldType = beanFieldType(context, field)
			if (!hidden) {
				beanClass.addField(camelCaseFieldName) [
					type = fieldType
					visibility = Visibility.PRIVATE
					initializer = [
						if (newTypeReference(List).isAssignableFrom(fieldType)) {
							'''new «toJavaCode(ArrayList.newTypeReference(fieldType.actualTypeArguments.get(0)))»()'''
						} else {
							defaultExpr(context, fieldType)
						}
					]
				]			
			}
			beanClass.addMethod("get" + camelCaseFieldName.toFirstUpper) [				
				visibility = Visibility.PUBLIC
				returnType = fieldType
				body = if (hidden) '''
						return «defaultExpr(context, fieldType)»;
				''' else '''
					return this.«camelCaseFieldName»;
				'''					
			]
			beanClass.addMethod("set" + camelCaseFieldName.toFirstUpper) [
				visibility = Visibility.PUBLIC
				addParameter("value", fieldType) 
				body = if (hidden) '''
					// hidden
				''' else {
					if (newTypeReference(List).isAssignableFrom(fieldType)) {
						'''
							this.«camelCaseFieldName».clear();
							if (value != null) {
								this.«camelCaseFieldName».addAll(value);
							}
						'''
					} else {
						'''
							this.«camelCaseFieldName» = value;
						'''
					}					
				}				
			]			
		}	
	}
	
	def String defaultExpr(extension TransformationContext context, TypeReference type) {
		val wrapper = type.wrapperIfPrimitive 
		switch wrapper {
			case wrapper == Boolean.newTypeReference: "false"
			case wrapper == Long.newTypeReference: "0l"
			case wrapper == Integer.newTypeReference: "0"
			case wrapper == Double.newTypeReference: "0.0"
			default: "null"
		}
	}
	
	private def TypeReference beanFieldType(extension TransformationContext context, MutableFieldDeclaration field) {
		val type = field.type.type
		if (type instanceof ClassDeclaration) {
			if (type.findAnnotation(JavaBean.findTypeGlobally) != null) {
				return newTypeReference(createdClassName(type))
			}
		}
		return field.type
	}
}