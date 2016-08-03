package de.scheidgen.xraw.util;

import com.google.common.base.Objects;
import com.google.gwt.core.client.GWT;
import com.google.gwt.core.client.RunAsyncCallback;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.logging.Logger;
import org.eclipse.xtend.lib.annotations.AccessorType;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;

@SuppressWarnings("all")
public class Async {
  public static class Join {
    private final Iterable<Async.Promise<?>> promises;
    
    private final Async.Defered<Void> defered = Async.<Void>defer();
    
    public Join(final Iterable<Async.Promise<?>> promises) {
      this.promises = promises;
      final Procedure1<Async.Promise<?>> _function = new Procedure1<Async.Promise<?>>() {
        @Override
        public void apply(final Async.Promise<?> it) {
          final Procedure1<Async.Promise<?>> _function = new Procedure1<Async.Promise<?>>() {
            @Override
            public void apply(final Async.Promise<?> it) {
              Join.this.applyJoin();
            }
          };
          it.then(_function);
        }
      };
      IterableExtensions.<Async.Promise<?>>forEach(promises, _function);
    }
    
    private void applyJoin() {
      final Function1<Async.Promise<?>, Boolean> _function = new Function1<Async.Promise<?>, Boolean>() {
        @Override
        public Boolean apply(final Async.Promise<?> it) {
          return Boolean.valueOf((!Objects.equal(it.state, Async.Promise.State.running)));
        }
      };
      boolean _forall = IterableExtensions.<Async.Promise<?>>forall(this.promises, _function);
      if (_forall) {
        final Function1<Async.Promise<?>, Boolean> _function_1 = new Function1<Async.Promise<?>, Boolean>() {
          @Override
          public Boolean apply(final Async.Promise<?> it) {
            return Boolean.valueOf(Objects.equal(it.state, Async.Promise.State.rejected));
          }
        };
        boolean _exists = IterableExtensions.<Async.Promise<?>>exists(this.promises, _function_1);
        if (_exists) {
          final Function1<Async.Promise<?>, Boolean> _function_2 = new Function1<Async.Promise<?>, Boolean>() {
            @Override
            public Boolean apply(final Async.Promise<?> it) {
              return Boolean.valueOf((!Objects.equal(it.cause, null)));
            }
          };
          Async.Promise<?> _findFirst = IterableExtensions.<Async.Promise<?>>findFirst(this.promises, _function_2);
          Throwable _cause = null;
          if (_findFirst!=null) {
            _cause=_findFirst.cause;
          }
          this.defered.reject(_cause);
        } else {
          this.defered.resolve(null);
        }
      }
    }
    
    public Async.Promise<Void> promise() {
      return this.defered.promise;
    }
  }
  
  public static abstract class Promise<T extends Object> {
    public enum State {
      resolved,
      
      rejected,
      
      running;
    }
    
    @Accessors(AccessorType.PUBLIC_GETTER)
    private T value = null;
    
    @Accessors(AccessorType.PUBLIC_GETTER)
    private Throwable cause = null;
    
    @Accessors(AccessorType.PUBLIC_GETTER)
    private Async.Promise.State state = Async.Promise.State.running;
    
    private final List<Procedure1<? super Async.Promise<T>>> actions = CollectionLiterals.<Procedure1<? super Async.Promise<T>>>newArrayList();
    
    private Promise() {
      Async.running.add(this);
      this.run();
    }
    
    public synchronized void resolve(final T result) {
      boolean _equals = Objects.equal(this.state, Async.Promise.State.running);
      if (_equals) {
        this.value = result;
        this.state = Async.Promise.State.resolved;
        this.apply();
        Async.running.remove(this);
      } else {
        Async.log.warning("Promise that was no longer running, was resolved (it was probably terminated by rejectAll)");
      }
    }
    
    public synchronized void reject(final Throwable cause) {
      boolean _equals = Objects.equal(this.state, Async.Promise.State.running);
      if (_equals) {
        this.state = Async.Promise.State.rejected;
        this.cause = cause;
        this.apply();
        Async.running.remove(this);
      } else {
        Async.log.warning("Promise that was no longer running, was resolved (it was probably terminated by rejectAll)");
      }
    }
    
    private void apply() {
      for (final Procedure1<? super Async.Promise<T>> action : this.actions) {
        action.apply(this);
      }
      this.actions.clear();
    }
    
    /**
     * Given callback is executed once the promise is resolved or rejected.
     */
    public synchronized void then(final Procedure1<? super Async.Promise<T>> action) {
      boolean _notEquals = (!Objects.equal(this.state, Async.Promise.State.running));
      if (_notEquals) {
        action.apply(this);
      } else {
        this.actions.add(action);
      }
    }
    
    /**
     * Allows to extend the promise with a new promise, once this promise is resolved.
     * The new promise will be rejected if this promise or the follow up promise is rejected.
     */
    public <R extends Object> Async.Promise<R> further(final Function1<? super T, ? extends Async.Promise<R>> action) {
      Async.Promise<R> _xblockexpression = null;
      {
        final Async.Defered<R> defer = Async.<R>defer();
        final Procedure1<Async.Promise<T>> _function = new Procedure1<Async.Promise<T>>() {
          @Override
          public void apply(final Async.Promise<T> oldPromise) {
            boolean _equals = Objects.equal(oldPromise.state, Async.Promise.State.rejected);
            if (_equals) {
              defer.reject(oldPromise.cause);
            } else {
              boolean _equals_1 = Objects.equal(oldPromise.state, Async.Promise.State.resolved);
              if (_equals_1) {
                final Async.Promise<R> basePromise = action.apply(oldPromise.value);
                final Procedure1<Async.Promise<R>> _function = new Procedure1<Async.Promise<R>>() {
                  @Override
                  public void apply(final Async.Promise<R> it) {
                    boolean _equals = Objects.equal(basePromise.state, Async.Promise.State.rejected);
                    if (_equals) {
                      defer.reject(basePromise.cause);
                    } else {
                      boolean _equals_1 = Objects.equal(basePromise.state, Async.Promise.State.resolved);
                      if (_equals_1) {
                        defer.resolve(basePromise.value);
                      } else {
                        throw new RuntimeException("Unreachable");
                      }
                    }
                  }
                };
                basePromise.then(_function);
              } else {
                throw new RuntimeException("Unreachable");
              }
            }
          }
        };
        this.then(_function);
        _xblockexpression = defer.promise;
      }
      return _xblockexpression;
    }
    
    public <R extends Object> Async.Promise<R> furtherPromise(final Function1<? super T, ? extends R> action) {
      Async.Promise<R> _xblockexpression = null;
      {
        final Async.Defered<R> defer = Async.<R>defer();
        final Procedure1<Async.Promise<T>> _function = new Procedure1<Async.Promise<T>>() {
          @Override
          public void apply(final Async.Promise<T> oldPromise) {
            boolean _equals = Objects.equal(oldPromise.state, Async.Promise.State.rejected);
            if (_equals) {
              defer.reject(oldPromise.cause);
            } else {
              boolean _equals_1 = Objects.equal(oldPromise.state, Async.Promise.State.resolved);
              if (_equals_1) {
                R _apply = action.apply(oldPromise.value);
                defer.resolve(_apply);
              } else {
                throw new RuntimeException("Unreachable");
              }
            }
          }
        };
        this.then(_function);
        _xblockexpression = defer.promise;
      }
      return _xblockexpression;
    }
    
    public Async.Promise<T> onResolve(final Procedure1<? super T> action) {
      Async.Promise<T> _xblockexpression = null;
      {
        final Procedure1<Async.Promise<T>> _function = new Procedure1<Async.Promise<T>>() {
          @Override
          public void apply(final Async.Promise<T> it) {
            boolean _equals = Objects.equal(it.state, Async.Promise.State.resolved);
            if (_equals) {
              action.apply(it.value);
            }
          }
        };
        this.then(_function);
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public Async.Promise<T> onReject(final Procedure1<? super Throwable> action) {
      Async.Promise<T> _xblockexpression = null;
      {
        final Procedure1<Async.Promise<T>> _function = new Procedure1<Async.Promise<T>>() {
          @Override
          public void apply(final Async.Promise<T> it) {
            boolean _equals = Objects.equal(it.state, Async.Promise.State.rejected);
            if (_equals) {
              action.apply(it.cause);
            }
          }
        };
        this.then(_function);
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public boolean isResolved() {
      return Objects.equal(this.state, Async.Promise.State.resolved);
    }
    
    public boolean isRejected() {
      return Objects.equal(this.state, Async.Promise.State.rejected);
    }
    
    protected abstract void run();
    
    @Pure
    public T getValue() {
      return this.value;
    }
    
    @Pure
    public Throwable getCause() {
      return this.cause;
    }
    
    @Pure
    public Async.Promise.State getState() {
      return this.state;
    }
  }
  
  public static class Defered<T extends Object> {
    private final Async.Promise<T> promise = new Async.Promise<T>() {
      @Override
      protected void run() {
      }
    };
    
    public Async.Promise<T> promise() {
      return this.promise;
    }
    
    public void resolve(final T result) {
      this.promise.resolve(result);
    }
    
    public void reject(final Throwable cause) {
      this.promise.reject(cause);
    }
  }
  
  private final static Logger log = Logger.getLogger(Async.class.getName());
  
  private final static Collection<Async.Promise<?>> running = CollectionLiterals.<Async.Promise<?>>newHashSet();
  
  public static void afterAll(final Procedure0 callback) {
    List<Async.Promise<?>> _list = IterableExtensions.<Async.Promise<?>>toList(Async.running);
    Async.Promise<?>[] _array = _list.<Async.Promise<?>>toArray(new Async.Promise[] {});
    Async.Promise<Void> _join = Async.join(_array);
    final Procedure1<Async.Promise<Void>> _function = new Procedure1<Async.Promise<Void>>() {
      @Override
      public void apply(final Async.Promise<Void> it) {
        callback.apply();
      }
    };
    _join.then(_function);
  }
  
  public static void rejectAll(final Throwable reason) {
    List<Async.Promise<?>> _list = IterableExtensions.<Async.Promise<?>>toList(Async.running);
    final Procedure1<Async.Promise<?>> _function = new Procedure1<Async.Promise<?>>() {
      @Override
      public void apply(final Async.Promise<?> it) {
        it.reject(reason);
      }
    };
    IterableExtensions.<Async.Promise<?>>forEach(_list, _function);
  }
  
  public static void run(final Procedure0 action) {
    GWT.runAsync(new RunAsyncCallback() {
      @Override
      public void onFailure(final Throwable reason) {
        Async.log.warning("Failure loading runAsync code.");
      }
      
      @Override
      public void onSuccess() {
        action.apply();
      }
    });
  }
  
  public static <T extends Object> Async.Promise<T> directPromise(final T value) {
    final Procedure1<Async.Promise<T>> _function = new Procedure1<Async.Promise<T>>() {
      @Override
      public void apply(final Async.Promise<T> it) {
        it.resolve(value);
      }
    };
    return Async.<T>promise(_function);
  }
  
  public static <T extends Object> Async.Promise<T> promise(final Procedure1<? super Async.Promise<T>> keep) {
    return new Async.Promise<T>() {
      @Override
      protected void run() {
        keep.apply(this);
      }
    };
  }
  
  public static <T extends Object> Async.Defered<T> defer() {
    return new Async.Defered<T>();
  }
  
  public static Async.Promise<Void> join(final Async.Promise<?>... promises) {
    ArrayList<Async.Promise<?>> _newArrayList = CollectionLiterals.<Async.Promise<?>>newArrayList(promises);
    Async.Join _join = new Async.Join(_newArrayList);
    return _join.promise();
  }
}
