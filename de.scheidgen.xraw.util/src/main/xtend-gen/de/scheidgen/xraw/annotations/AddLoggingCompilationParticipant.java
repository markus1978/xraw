package de.scheidgen.xraw.annotations;

import com.google.common.base.Objects;
import de.scheidgen.xraw.annotations.AddLogging;
import java.util.List;
import java.util.logging.Logger;
import org.eclipse.xtend.lib.macro.TransformationContext;
import org.eclipse.xtend.lib.macro.TransformationParticipant;
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference;
import org.eclipse.xtend.lib.macro.declaration.AnnotationTypeDeclaration;
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy;
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration;
import org.eclipse.xtend.lib.macro.declaration.Type;
import org.eclipse.xtend.lib.macro.declaration.TypeReference;
import org.eclipse.xtend.lib.macro.declaration.Visibility;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class AddLoggingCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {
  @Override
  public void doTransform(final List<? extends MutableClassDeclaration> annotatedTargetElements, @Extension final TransformationContext context) {
    for (final MutableClassDeclaration clazz : annotatedTargetElements) {
      {
        Iterable<? extends AnnotationReference> _annotations = clazz.getAnnotations();
        final Function1<AnnotationReference, Boolean> _function = new Function1<AnnotationReference, Boolean>() {
          @Override
          public Boolean apply(final AnnotationReference it) {
            AnnotationTypeDeclaration _annotationTypeDeclaration = it.getAnnotationTypeDeclaration();
            Type _findTypeGlobally = context.findTypeGlobally(AddLogging.class);
            return Boolean.valueOf(Objects.equal(_annotationTypeDeclaration, _findTypeGlobally));
          }
        };
        final AnnotationReference annotation = IterableExtensions.findFirst(_annotations, _function);
        clazz.removeAnnotation(annotation);
        final Procedure1<MutableFieldDeclaration> _function_1 = new Procedure1<MutableFieldDeclaration>() {
          @Override
          public void apply(final MutableFieldDeclaration it) {
            it.setStatic(true);
            it.setVisibility(Visibility.PRIVATE);
            TypeReference _newTypeReference = context.newTypeReference(Logger.class);
            it.setType(_newTypeReference);
            final CompilationStrategy _function = new CompilationStrategy() {
              @Override
              public CharSequence compile(final CompilationStrategy.CompilationContext it) {
                StringConcatenation _builder = new StringConcatenation();
                TypeReference _newTypeReference = context.newTypeReference(Logger.class);
                String _javaCode = it.toJavaCode(_newTypeReference);
                _builder.append(_javaCode, "");
                _builder.append(".getLogger(");
                TypeReference _newTypeReference_1 = context.newTypeReference(clazz);
                String _javaCode_1 = it.toJavaCode(_newTypeReference_1);
                _builder.append(_javaCode_1, "");
                _builder.append(".class.getName())");
                return _builder;
              }
            };
            it.setInitializer(_function);
          }
        };
        clazz.addField("log", _function_1);
      }
    }
  }
}
