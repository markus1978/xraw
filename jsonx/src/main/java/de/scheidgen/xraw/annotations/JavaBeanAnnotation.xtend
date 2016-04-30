package de.scheidgen.xraw.annotations

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.Active
import java.lang.annotation.Target

@Active(JavaBeanAnnotationClassProcessor)
@Target(TYPE)
annotation JavaBean {
	
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
			val camelCaseFieldName = NameUtil.snakeCaseToCamelCase(field.simpleName)
			beanClass.addField(camelCaseFieldName) [
				type = field.type
				visibility = Visibility.PRIVATE
			]
			beanClass.addMethod("get" + camelCaseFieldName.toFirstUpper) [
				visibility = Visibility.PUBLIC
				returnType = field.type
				body = '''
					return this.«camelCaseFieldName»;
				'''
			]
			beanClass.addMethod("set" + camelCaseFieldName.toFirstUpper) [
				visibility = Visibility.PUBLIC
				addParameter("value", field.type) 
				body = '''
					this.«camelCaseFieldName» = value;
				'''				
			]			
		}	
	}
	
}