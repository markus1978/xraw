package de.scheidgen.xraw.annotations;

import com.google.common.base.Objects;
import de.scheidgen.xraw.annotations.AddConstructor;
import java.util.List;
import org.eclipse.xtend.lib.macro.TransformationContext;
import org.eclipse.xtend.lib.macro.TransformationParticipant;
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference;
import org.eclipse.xtend.lib.macro.declaration.AnnotationTypeDeclaration;
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration;
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy;
import org.eclipse.xtend.lib.macro.declaration.ConstructorDeclaration;
import org.eclipse.xtend.lib.macro.declaration.EnumerationValueDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableConstructorDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableParameterDeclaration;
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration;
import org.eclipse.xtend.lib.macro.declaration.Type;
import org.eclipse.xtend.lib.macro.declaration.TypeReference;
import org.eclipse.xtend.lib.macro.declaration.Visibility;
import org.eclipse.xtend.lib.macro.expression.Expression;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class AddConstructorCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {
  public MutableConstructorDeclaration addConstructor(final MutableClassDeclaration clazz, @Extension final TransformationContext context, final ConstructorDeclaration superConstructor) {
    final Procedure1<MutableConstructorDeclaration> _function = new Procedure1<MutableConstructorDeclaration>() {
      @Override
      public void apply(final MutableConstructorDeclaration it) {
        boolean _notEquals = (!Objects.equal(superConstructor, null));
        if (_notEquals) {
          Iterable<? extends ParameterDeclaration> _parameters = superConstructor.getParameters();
          for (final ParameterDeclaration superParam : _parameters) {
            String _simpleName = superParam.getSimpleName();
            TypeReference _type = superParam.getType();
            it.addParameter(_simpleName, _type);
          }
          Visibility _visibility = superConstructor.getVisibility();
          it.setVisibility(_visibility);
        } else {
          Type _findTypeGlobally = context.findTypeGlobally(AddConstructor.class);
          AnnotationReference _findAnnotation = clazz.findAnnotation(_findTypeGlobally);
          EnumerationValueDeclaration _enumValue = _findAnnotation.getEnumValue("value");
          String _simpleName_1 = _enumValue.getSimpleName();
          Visibility _valueOf = Visibility.valueOf(_simpleName_1);
          it.setVisibility(_valueOf);
        }
        Type _findTypeGlobally_1 = context.findTypeGlobally(AddConstructor.class);
        AnnotationReference _findAnnotation_1 = clazz.findAnnotation(_findTypeGlobally_1);
        TypeReference[] _classArrayValue = _findAnnotation_1.getClassArrayValue("value");
        for (final TypeReference annotation : _classArrayValue) {
          Type _type_1 = annotation.getType();
          AnnotationReference _newAnnotationReference = context.newAnnotationReference(_type_1);
          it.addAnnotation(_newAnnotationReference);
        }
        Iterable<? extends MutableFieldDeclaration> _declaredFields = clazz.getDeclaredFields();
        final Function1<MutableFieldDeclaration, Boolean> _function = new Function1<MutableFieldDeclaration, Boolean>() {
          @Override
          public Boolean apply(final MutableFieldDeclaration it) {
            boolean _and = false;
            boolean _isFinal = it.isFinal();
            if (!_isFinal) {
              _and = false;
            } else {
              Expression _initializer = it.getInitializer();
              boolean _equals = Objects.equal(_initializer, null);
              _and = _equals;
            }
            return Boolean.valueOf(_and);
          }
        };
        Iterable<? extends MutableFieldDeclaration> _filter = IterableExtensions.filter(_declaredFields, _function);
        final Function1<MutableFieldDeclaration, Boolean> _function_1 = new Function1<MutableFieldDeclaration, Boolean>() {
          @Override
          public Boolean apply(final MutableFieldDeclaration it) {
            Iterable<? extends AnnotationReference> _annotations = it.getAnnotations();
            final Function1<AnnotationReference, Boolean> _function = new Function1<AnnotationReference, Boolean>() {
              @Override
              public Boolean apply(final AnnotationReference it) {
                AnnotationTypeDeclaration _annotationTypeDeclaration = it.getAnnotationTypeDeclaration();
                String _simpleName = _annotationTypeDeclaration.getSimpleName();
                return Boolean.valueOf(Objects.equal(_simpleName, "Inject"));
              }
            };
            boolean _exists = IterableExtensions.exists(_annotations, _function);
            return Boolean.valueOf((!_exists));
          }
        };
        final Iterable<? extends MutableFieldDeclaration> finalUninitializedFields = IterableExtensions.filter(_filter, _function_1);
        for (final MutableFieldDeclaration field : finalUninitializedFields) {
          String _simpleName_2 = field.getSimpleName();
          TypeReference _type_2 = field.getType();
          it.addParameter(_simpleName_2, _type_2);
        }
        final CompilationStrategy _function_2 = new CompilationStrategy() {
          @Override
          public CharSequence compile(final CompilationStrategy.CompilationContext it) {
            StringConcatenation _builder = new StringConcatenation();
            {
              boolean _equals = Objects.equal(superConstructor, null);
              if (_equals) {
                _builder.append("super();");
                _builder.newLine();
              } else {
                _builder.append("super(");
                {
                  Iterable<? extends ParameterDeclaration> _parameters = superConstructor.getParameters();
                  boolean _hasElements = false;
                  for(final ParameterDeclaration superParam : _parameters) {
                    if (!_hasElements) {
                      _hasElements = true;
                    } else {
                      _builder.appendImmediate(", ", "");
                    }
                    String _simpleName = superParam.getSimpleName();
                    _builder.append(_simpleName, "");
                  }
                }
                _builder.append(");");
                _builder.newLineIfNotEmpty();
              }
            }
            {
              for(final MutableFieldDeclaration field : finalUninitializedFields) {
                _builder.append("this.");
                String _simpleName_1 = field.getSimpleName();
                _builder.append(_simpleName_1, "");
                _builder.append(" = ");
                String _simpleName_2 = field.getSimpleName();
                _builder.append(_simpleName_2, "");
                _builder.append(";");
                _builder.newLineIfNotEmpty();
              }
            }
            {
              Iterable<? extends MutableMethodDeclaration> _declaredMethods = clazz.getDeclaredMethods();
              final Function1<MutableMethodDeclaration, Boolean> _function = new Function1<MutableMethodDeclaration, Boolean>() {
                @Override
                public Boolean apply(final MutableMethodDeclaration it) {
                  boolean _and = false;
                  String _simpleName = it.getSimpleName();
                  boolean _equals = Objects.equal(_simpleName, "onNew");
                  if (!_equals) {
                    _and = false;
                  } else {
                    Iterable<? extends MutableParameterDeclaration> _parameters = it.getParameters();
                    boolean _isEmpty = IterableExtensions.isEmpty(_parameters);
                    _and = _isEmpty;
                  }
                  return Boolean.valueOf(_and);
                }
              };
              MutableMethodDeclaration _findFirst = IterableExtensions.findFirst(_declaredMethods, _function);
              boolean _notEquals = (!Objects.equal(_findFirst, null));
              if (_notEquals) {
                _builder.append("onNew();");
                _builder.newLine();
              }
            }
            return _builder;
          }
        };
        it.setBody(_function_2);
      }
    };
    return clazz.addConstructor(_function);
  }
  
  @Override
  public void doTransform(final List<? extends MutableClassDeclaration> annotatedTargetElements, @Extension final TransformationContext context) {
    for (final MutableClassDeclaration clazz : annotatedTargetElements) {
      TypeReference _extendedClass = clazz.getExtendedClass();
      boolean _equals = Objects.equal(_extendedClass, null);
      if (_equals) {
        this.addConstructor(clazz, context, null);
      } else {
        TypeReference _extendedClass_1 = clazz.getExtendedClass();
        Type _type = _extendedClass_1.getType();
        final ClassDeclaration superClassDeclaration = ((ClassDeclaration) _type);
        Iterable<? extends ConstructorDeclaration> _declaredConstructors = superClassDeclaration.getDeclaredConstructors();
        final Function1<ConstructorDeclaration, Boolean> _function = new Function1<ConstructorDeclaration, Boolean>() {
          @Override
          public Boolean apply(final ConstructorDeclaration it) {
            Visibility _visibility = it.getVisibility();
            return Boolean.valueOf((!Objects.equal(_visibility, Visibility.PRIVATE)));
          }
        };
        Iterable<? extends ConstructorDeclaration> _filter = IterableExtensions.filter(_declaredConstructors, _function);
        final Procedure1<ConstructorDeclaration> _function_1 = new Procedure1<ConstructorDeclaration>() {
          @Override
          public void apply(final ConstructorDeclaration it) {
            AddConstructorCompilationParticipant.this.addConstructor(clazz, context, it);
          }
        };
        IterableExtensions.forEach(_filter, _function_1);
      }
    }
  }
}
