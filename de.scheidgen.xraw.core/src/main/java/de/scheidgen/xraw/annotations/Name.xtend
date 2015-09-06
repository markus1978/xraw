package de.scheidgen.xraw.annotations

import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration

annotation Name {
	String value
}

class NameUtil {
	static def name(extension TransformationContext context, MutableFieldDeclaration field) {
		val nameAnnotation = field.findAnnotation(typeof(Name).findTypeGlobally)
		return if (nameAnnotation == null) field.simpleName else nameAnnotation.getStringValue('value') 
	}
	
	static def snakeCaseToCamelCase(String source) {
		val parts = source.split("_")
		val target = parts.join("") [
			it.toFirstUpper
		]
		return if (source.equals(source.toFirstLower)) target.toFirstLower else target
	}
}