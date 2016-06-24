package de.scheidgen.xraw.annotations

import java.lang.annotation.Target
import jsinterop.annotations.JsOverlay
import jsinterop.annotations.JsType
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.jdt.internal.compiler.ast.TypeDeclaration
import com.google.gwt.core.client.GWT
import de.scheidgen.xraw.json.InitNativeJSTypes

@Active(JavaScriptAnnotationClassProcessor)
@Target(TYPE)
annotation JavaScript {
	
}

class JavaScriptAnnotationClassProcessor extends AbstractClassProcessor {
	
	public static def createdClassName(ClassDeclaration annotatedClass) {
		annotatedClass.qualifiedName + "JS"
	}
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		super.doRegisterGlobals(annotatedClass, context)
		context.registerClass(annotatedClass.createdClassName)
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		super.doTransform(annotatedClass, context)
		val jsClass = context.findClass(annotatedClass.createdClassName)
		
		val jsTypeReference = JsType.newAnnotationReference [
			it.set('isNative', Boolean.TRUE)
		]
		jsClass.addAnnotation(jsTypeReference)
		
		jsClass.addConstructor[
			visibility = Visibility.PRIVATE
			body = ''''''
		]
		
		val fields = newArrayList
		for(field: annotatedClass.declaredFields) {
			val hidden = field.findAnnotation(Hidden.findTypeGlobally) != null
			val camelCaseFieldName = NameUtil.snakeCaseToCamelCase(field.simpleName)
			val fieldType = jsFieldType(context, field)
			if (!hidden) {
				fields += field
				jsClass.addField(camelCaseFieldName) [
					type = fieldType
					visibility = Visibility.PUBLIC
				]			
			}			
		}	
		
		jsClass.addMethod("updateFrom") [
			addAnnotation(JsOverlay.newAnnotationReference)
			visibility = Visibility.PUBLIC
			final = true
			addParameter("source", annotatedClass.newTypeReference)
			body = ['''
				«FOR field: fields»
					«NameUtil.snakeCaseToCamelCase(field.simpleName)» = source.«"get" + NameUtil.snakeCaseToCamelCase(field.simpleName).toFirstUpper»();
				«ENDFOR»
			''']
		]
		jsClass.addMethod("updateTo") [
			visibility = Visibility.PUBLIC
			addAnnotation(JsOverlay.newAnnotationReference)
			addParameter("target", annotatedClass.newTypeReference)
			final = true
			body = ['''
				«FOR field: fields»
					target.«"set" + NameUtil.snakeCaseToCamelCase(field.simpleName).toFirstUpper»(«NameUtil.snakeCaseToCamelCase(field.simpleName)»);
				«ENDFOR» 
			''']
		]
		jsClass.addMethod("create") [
			visibility = Visibility.PUBLIC
			static = true
			addAnnotation(JsOverlay.newAnnotationReference)
			final = true
			returnType = jsClass.newTypeReference
			body = ['''
				if («toJavaCode(GWT.newTypeReference)».isScript()) {
					«toJavaCode(InitNativeJSTypes.newTypeReference())».init(new String[] {«annotatedClass.createdClassName.split("\\.").map['''"«it»"'''.toString].join(", ")»});
				}
				return new «toJavaCode(jsClass.newTypeReference)»();
			''']
		]
	}
	
	private def TypeReference jsFieldType(extension TransformationContext context, MutableFieldDeclaration field) {
		val type = field.type.type
		if (type instanceof ClassDeclaration) {
			if (type.findAnnotation(JavaBean.findTypeGlobally) != null) {
				return newTypeReference(createdClassName(type))
			}
		}
		return field.type
	}
}