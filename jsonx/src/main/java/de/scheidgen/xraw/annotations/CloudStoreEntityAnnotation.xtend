package de.scheidgen.xraw.annotations

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(CloudStoreEntityAnnotationClassProcessor)
@Target(TYPE)
annotation CloudStoreEntity {
	
}

@Target(TYPE)
annotation Embedded {}

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
		
		val embedded = annotatedClass.findAnnotation(Embedded.findTypeGlobally) != null
		
		val embeddedEntityTypeRef = newTypeReference("com.google.appengine.api.datastore.EmbeddedEntity")
		val entityTypeRef = if (embedded) {
			embeddedEntityTypeRef
		} else {
			newTypeReference("com.google.appengine.api.datastore.Entity")		
		} 
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
			val fieldType = entityFieldType(context, field)
			entityClass.addMethod("get" + camelCaseFieldName.toFirstUpper) [
				visibility = Visibility.PUBLIC
				returnType = entityFieldType(context, field)
				body = ['''
					Object value = this.entity.getProperty("«field.simpleName»");
					«IF fieldType.primitive»
						if (value == null) {
							return «defaultExpr(context, fieldType)»;
						} else {
							return («toJavaCode(fieldType)»)value;
						}
					«ELSE»
						«IF (isEntityField(context, field))»
							return «toJavaCode(newTypeReference(createdClassName(field.type.type as ClassDeclaration)))».create((«toJavaCode(embeddedEntityTypeRef)»)value);
						«ELSE»
							return («toJavaCode(fieldType)»)value;
						«ENDIF»
					«ENDIF»
				''']
			]
			entityClass.addMethod("set" + camelCaseFieldName.toFirstUpper) [
				visibility = Visibility.PUBLIC
				addParameter("value", fieldType) 
				body = '''
					«IF (isEntityField(context, field))»
						entity.setProperty("«field.simpleName»", value.xEntity());
					«ELSE»
						entity.setProperty("«field.simpleName»", value);
					«ENDIF»
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
						bean.set«NameUtil.snakeCaseToCamelCase(field.simpleName).toFirstUpper»(«valueAccess(context, field)»);
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
	
	private static def valueAccess(extension TransformationContext context, FieldDeclaration field) {
		if (isEntityField(context, field)) {
			'''this.get«NameUtil.snakeCaseToCamelCase(field.simpleName).toFirstUpper»().toBean()'''
		} else {
			'''this.get«NameUtil.snakeCaseToCamelCase(field.simpleName).toFirstUpper»()'''		
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
	
	private static def boolean isEntityField(extension TransformationContext context, FieldDeclaration field) {
		val type = field.type.type
		if (type instanceof ClassDeclaration) {
			if (type.findAnnotation(CloudStoreEntity.findTypeGlobally) != null) {
				return true
			}			
		}
		return false
	}
	
	private def TypeReference entityFieldType(extension TransformationContext context, FieldDeclaration field) {		
		if (isEntityField(context, field)) {
			return newTypeReference(createdClassName(field.type.type as ClassDeclaration))
		}
		return field.type
	}
}