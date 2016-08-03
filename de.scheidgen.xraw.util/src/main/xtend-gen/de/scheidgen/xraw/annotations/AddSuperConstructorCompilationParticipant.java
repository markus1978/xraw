package de.scheidgen.xraw.annotations;

import com.google.common.base.Objects;
import de.scheidgen.xraw.annotations.AddSuperConstructors;
import java.util.List;
import org.eclipse.xtend.lib.macro.TransformationContext;
import org.eclipse.xtend.lib.macro.TransformationParticipant;
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference;
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration;
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy;
import org.eclipse.xtend.lib.macro.declaration.ConstructorDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableConstructorDeclaration;
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration;
import org.eclipse.xtend.lib.macro.declaration.Type;
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration;
import org.eclipse.xtend.lib.macro.declaration.TypeReference;
import org.eclipse.xtend.lib.macro.declaration.Visibility;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class AddSuperConstructorCompilationParticipant implements TransformationParticipant<MutableClassDeclaration> {
  @Override
  public void doTransform(final List<? extends MutableClassDeclaration> annotatedTargetElements, @Extension final TransformationContext context) {
    for (final MutableClassDeclaration clazz : annotatedTargetElements) {
      {
        TypeReference _extendedClass = clazz.getExtendedClass();
        boolean _equals = Objects.equal(_extendedClass, null);
        if (_equals) {
          Type _findTypeGlobally = context.findTypeGlobally(AddSuperConstructors.class);
          AnnotationReference _findAnnotation = clazz.findAnnotation(_findTypeGlobally);
          context.addError(_findAnnotation, "Class has no super class.");
        }
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
        for (final ConstructorDeclaration superConstructor : _filter) {
          final Procedure1<MutableConstructorDeclaration> _function_1 = new Procedure1<MutableConstructorDeclaration>() {
            @Override
            public void apply(final MutableConstructorDeclaration it) {
              Type _findTypeGlobally = context.findTypeGlobally(AddSuperConstructors.class);
              AnnotationReference _findAnnotation = clazz.findAnnotation(_findTypeGlobally);
              TypeReference[] _classArrayValue = _findAnnotation.getClassArrayValue("value");
              for (final TypeReference annotation : _classArrayValue) {
                Type _type = annotation.getType();
                AnnotationReference _newAnnotationReference = context.newAnnotationReference(_type);
                it.addAnnotation(_newAnnotationReference);
              }
              Visibility _visibility = superConstructor.getVisibility();
              it.setVisibility(_visibility);
              Iterable<? extends ParameterDeclaration> _parameters = superConstructor.getParameters();
              for (final ParameterDeclaration superParam : _parameters) {
                {
                  Iterable<? extends TypeParameterDeclaration> _typeParameters = superClassDeclaration.getTypeParameters();
                  Iterable<Pair<Integer, TypeParameterDeclaration>> _indexed = IterableExtensions.<TypeParameterDeclaration>indexed(_typeParameters);
                  final Function1<Pair<Integer, TypeParameterDeclaration>, Boolean> _function = new Function1<Pair<Integer, TypeParameterDeclaration>, Boolean>() {
                    @Override
                    public Boolean apply(final Pair<Integer, TypeParameterDeclaration> it) {
                      TypeParameterDeclaration _value = it.getValue();
                      String _simpleName = _value.getSimpleName();
                      TypeReference _type = superParam.getType();
                      String _name = _type.getName();
                      return Boolean.valueOf(Objects.equal(_simpleName, _name));
                    }
                  };
                  Pair<Integer, TypeParameterDeclaration> _findFirst = IterableExtensions.<Pair<Integer, TypeParameterDeclaration>>findFirst(_indexed, _function);
                  Integer _key = null;
                  if (_findFirst!=null) {
                    _key=_findFirst.getKey();
                  }
                  final Integer typeParamIndex = _key;
                  TypeReference _xifexpression = null;
                  boolean _notEquals = (!Objects.equal(typeParamIndex, null));
                  if (_notEquals) {
                    TypeReference _extendedClass = clazz.getExtendedClass();
                    List<TypeReference> _actualTypeArguments = _extendedClass.getActualTypeArguments();
                    _xifexpression = _actualTypeArguments.get((typeParamIndex).intValue());
                  } else {
                    _xifexpression = superParam.getType();
                  }
                  final TypeReference type = _xifexpression;
                  String _simpleName = superParam.getSimpleName();
                  it.addParameter(_simpleName, type);
                }
              }
              final CompilationStrategy _function = new CompilationStrategy() {
                @Override
                public CharSequence compile(final CompilationStrategy.CompilationContext it) {
                  StringConcatenation _builder = new StringConcatenation();
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
                  return _builder;
                }
              };
              it.setBody(_function);
            }
          };
          clazz.addConstructor(_function_1);
        }
        Type _findTypeGlobally_1 = context.findTypeGlobally(AddSuperConstructors.class);
        AnnotationReference _findAnnotation_1 = clazz.findAnnotation(_findTypeGlobally_1);
        clazz.removeAnnotation(_findAnnotation_1);
      }
    }
  }
}
