package de.scheidgen.xraw.util;

import com.google.common.base.Objects;
import com.google.common.collect.AbstractIterator;
import com.google.common.collect.FluentIterable;
import com.google.common.collect.Iterables;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;

@SuppressWarnings("all")
public class XRawIterateExtensions {
  private static class Result<T extends Object> implements Iterator<T> {
    private ArrayList<T> elements = new ArrayList<T>();
    
    private ArrayList<Iterable<T>> iterables = new ArrayList<Iterable<T>>();
    
    public synchronized void add(final T element) {
      this.elements.add(element);
    }
    
    public synchronized void addAll(final Iterable<T> iterable) {
      this.iterables.add(iterable);
    }
    
    public synchronized Iterator<T> reset() {
      Iterator<T> _xblockexpression = null;
      {
        this.elements.clear();
        this.iterables.clear();
        this.iterables.add(this.elements);
        _xblockexpression = this.iterator = null;
      }
      return _xblockexpression;
    }
    
    private Iterator<T> iterator = null;
    
    @Override
    public boolean hasNext() {
      boolean _equals = Objects.equal(this.iterator, null);
      if (_equals) {
        Iterable<T> _flatten = Iterables.<T>concat(this.iterables);
        Iterator<T> _iterator = _flatten.iterator();
        this.iterator = _iterator;
      }
      return this.iterator.hasNext();
    }
    
    @Override
    public T next() {
      boolean _equals = Objects.equal(this.iterator, null);
      if (_equals) {
        Iterable<T> _flatten = Iterables.<T>concat(this.iterables);
        Iterator<T> _iterator = _flatten.iterator();
        this.iterator = _iterator;
      }
      return this.iterator.next();
    }
    
    @Override
    public void remove() {
      throw new UnsupportedOperationException("Not supported, iterable is immutable.");
    }
  }
  
  private static <E extends Object, T extends Object> Iterable<T> standardIterate(final Iterable<E> source, final Function2<E, XRawIterateExtensions.Result<T>, Void> function) {
    return new FluentIterable<T>() {
      @Override
      public Iterator<T> iterator() {
        final Iterator<E> sourceIterator = source.iterator();
        final XRawIterateExtensions.Result<T> nextResult = new XRawIterateExtensions.Result<T>();
        return new AbstractIterator<T>() {
          @Override
          protected T computeNext() {
            boolean _hasNext = nextResult.hasNext();
            if (_hasNext) {
              return nextResult.next();
            } else {
              while (sourceIterator.hasNext()) {
                {
                  final E next = sourceIterator.next();
                  nextResult.reset();
                  function.apply(next, nextResult);
                  boolean _hasNext_1 = nextResult.hasNext();
                  if (_hasNext_1) {
                    return nextResult.next();
                  }
                }
              }
              return this.endOfData();
            }
          }
        };
      }
    };
  }
  
  private static <E extends Object, T extends Object> Iterable<T> concurrentIterate(final Iterable<E> source, final Function2<E, XRawIterateExtensions.Result<T>, Void> function) {
    return null;
  }
  
  public static XRawIterateExtensions standard() {
    final Function2<Iterable, Function2, Iterable> _function = new Function2<Iterable, Function2, Iterable>() {
      @Override
      public Iterable apply(final Iterable source, final Function2 function) {
        return XRawIterateExtensions.<Object, Object>standardIterate(source, function);
      }
    };
    return new XRawIterateExtensions(_function);
  }
  
  public static XRawIterateExtensions concurrent() {
    final Function2<Iterable, Function2, Iterable> _function = new Function2<Iterable, Function2, Iterable>() {
      @Override
      public Iterable apply(final Iterable source, final Function2 function) {
        return XRawIterateExtensions.<Object, Object>concurrentIterate(source, function);
      }
    };
    return new XRawIterateExtensions(_function);
  }
  
  private final Function2<? super Iterable, ? super Function2, ? extends Iterable> untypedIterate;
  
  private XRawIterateExtensions(final Function2<? super Iterable, ? super Function2, ? extends Iterable> untypedIterate) {
    this.untypedIterate = untypedIterate;
  }
  
  public <E extends Object, T extends Object> Iterable<T> iterate(final Iterable<E> source, final Function2<E, XRawIterateExtensions.Result<T>, Void> function) {
    return this.untypedIterate.apply(source, function);
  }
  
  public <E extends Object, T extends Object> Iterable<T> collect(final Iterable<E> source, final Function1<E, T> function) {
    final Function2<E, XRawIterateExtensions.Result<T>, Void> _function = new Function2<E, XRawIterateExtensions.Result<T>, Void>() {
      @Override
      public Void apply(final E element, final XRawIterateExtensions.Result<T> result) {
        T _apply = function.apply(element);
        result.add(_apply);
        return null;
      }
    };
    return this.<E, T>iterate(source, _function);
  }
  
  public <E extends Object, T extends Object> Iterable<T> collectAll(final Iterable<E> source, final Function1<E, ? extends Iterable<T>> function) {
    final Function2<E, XRawIterateExtensions.Result<T>, Void> _function = new Function2<E, XRawIterateExtensions.Result<T>, Void>() {
      @Override
      public Void apply(final E element, final XRawIterateExtensions.Result<T> result) {
        Iterable<T> _apply = function.apply(element);
        result.addAll(_apply);
        return null;
      }
    };
    return this.<E, T>iterate(source, _function);
  }
  
  public <E extends Object> Iterable<E> select(final Iterable<E> source, final Function1<E, Boolean> function) {
    final Function2<E, XRawIterateExtensions.Result<E>, Void> _function = new Function2<E, XRawIterateExtensions.Result<E>, Void>() {
      @Override
      public Void apply(final E element, final XRawIterateExtensions.Result<E> result) {
        Boolean _apply = function.apply(element);
        if ((_apply).booleanValue()) {
          result.add(element);
        }
        return null;
      }
    };
    return this.<E, E>iterate(source, _function);
  }
  
  public <E extends Object> Iterable<E> closure(final Iterable<E> source, final Function1<E, Iterable<E>> function) {
    final Function2<E, XRawIterateExtensions.Result<E>, Void> _function = new Function2<E, XRawIterateExtensions.Result<E>, Void>() {
      @Override
      public Void apply(final E element, final XRawIterateExtensions.Result<E> result) {
        result.add(element);
        Iterable<E> _apply = function.apply(element);
        Iterable<E> _closure = XRawIterateExtensions.this.<E>closure(_apply, function);
        result.addAll(_closure);
        return null;
      }
    };
    return this.<E, E>iterate(source, _function);
  }
  
  public <E extends Object> Iterable<E> closure(final E source, final Function1<E, Iterable<E>> function) {
    return this.<E>closure(Collections.<E>unmodifiableSet(CollectionLiterals.<E>newHashSet(source)), function);
  }
  
  public <E extends Object> void foreach(final Iterable<E> source, final Function1<E, Void> function) {
    final Function2<E, XRawIterateExtensions.Result<Object>, Void> _function = new Function2<E, XRawIterateExtensions.Result<Object>, Void>() {
      @Override
      public Void apply(final E element, final XRawIterateExtensions.Result<Object> result) {
        return function.apply(element);
      }
    };
    this.<E, Object>iterate(source, _function);
  }
}
