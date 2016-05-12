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

@Active(CloudStoreEntityAnnotationClassProcessor)
@Target(TYPE)
annotation CloudStoreEntity {
	
}

class CloudStoreEntityAnnotationClassProcessor extends AbstractClassProcessor {
	
	public static def createdClassName(ClassDeclaration annotatedClass) {
		annotatedClass.qualifiedName + "Entity"
	}
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		super.doRegisterGlobals(annotatedClass, context)
		context.registerClass(annotatedClass.createdClassName)
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		super.doTransform(annotatedClass, context)
		val entityClass = context.findClass(annotatedClass.createdClassName)
		val allFields = annotatedClass.declaredFields
		
		val entityTypeRef = newTypeReference("com.google.appengine.api.datastore.Entity")
		val keyFactoryTypeRef = newTypeReference("com.google.appengine.api.datastore.KeyFactory")
		val keyTypeRef = newTypeReference("com.google.appengine.api.datastore.Key")
		
		entityClass.addField("kind") [
			visibility = Visibility.PRIVATE	
			static = true
			type = string
			initializer = '''"«annotatedClass.simpleName»"'''
		]
		
		entityClass.addMethod("getKind") [
			static = true
			visibility = Visibility.PUBLIC
			returnType = string
			body = '''return kind;'''
		]
		
		entityClass.addField("entity") [
			type = entityTypeRef
			visibility = Visibility.PRIVATE			
		]
		
		entityClass.addConstructor[
			visibility = Visibility.PRIVATE
			addParameter("entity", entityTypeRef)
			body = '''
				this.entity = entity;
			'''
		]
		
		entityClass.addMethod("create") [
			static = true
			visibility = Visibility.PUBLIC
			addParameter("entity", entityTypeRef)
			returnType = newTypeReference(entityClass)
			body = ['''
				return new «toJavaCode(newTypeReference(entityClass))»(entity);
			''']
		]
		
		for(field: allFields) {
			val camelCaseFieldName = NameUtil.snakeCaseToCamelCase(field.simpleName)
			entityClass.addMethod("get" + camelCaseFieldName.toFirstUpper) [
				visibility = Visibility.PUBLIC
				returnType = field.type
				
				body = ['''
					Object value = this.entity.getProperty("«field.simpleName»");
					«IF field.type.primitive»
						if (value == null) {
							return «defaultExpr(context, field.type)»;
						} else {
							return («toJavaCode(field.type)»)value;
						}
					«ELSE»
						return («toJavaCode(field.type)»)value;
					«ENDIF»
				''']
			]
			entityClass.addMethod("set" + camelCaseFieldName.toFirstUpper) [
				visibility = Visibility.PUBLIC
				addParameter("value", field.type) 
				body = '''
					entity.setProperty("«field.simpleName»", value);
				'''				
			]			
		}
		
		entityClass.addMethod("xEntity") [
			returnType = entityTypeRef
			body = '''
				return entity;
			'''
		]
		
		entityClass.addMethod("key") [
			visibility = Visibility.PUBLIC
			static = true
			addParameter("key", String.newTypeReference)
			returnType = keyTypeRef
			body = ['''
				return «toJavaCode(keyFactoryTypeRef)».createKey(kind, key);
			''']
		]
		
		entityClass.addMethod("key") [
			visibility = Visibility.PUBLIC
			static = true
			addParameter("parent", keyTypeRef)
			addParameter("key", String.newTypeReference)			
			returnType = keyTypeRef
			body = ['''
				return «toJavaCode(keyFactoryTypeRef)».createKey(parent, kind, key);
			''']
		]
			
		val beanClassName = JavaBeanAnnotationClassProcessor.createdClassName(annotatedClass)
		val beanClass = context.findClass(beanClassName)
		if (beanClass != null) {
			entityClass.addMethod("toBean") [
				returnType = beanClass.newTypeReference
				visibility = Visibility.PUBLIC
				body = ['''
					«toJavaCode(beanClass.newTypeReference)» bean = new «toJavaCode(beanClass.newTypeReference)»();
					«FOR field:allFields»
						bean.set«NameUtil.snakeCaseToCamelCase(field.simpleName).toFirstUpper»(this.get«NameUtil.snakeCaseToCamelCase(field.simpleName).toFirstUpper»());
					«ENDFOR»
					return bean; 
				''']
			]
			entityClass.addMethod("toBean") [
				returnType = beanClass.newTypeReference
				addParameter("entity", entityTypeRef)
				static = true
				visibility = Visibility.PUBLIC
				body = ['''
					return create(entity).toBean();	
				''']
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
}