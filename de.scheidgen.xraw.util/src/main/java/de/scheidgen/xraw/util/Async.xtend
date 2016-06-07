package de.scheidgen.xraw.util

import com.google.gwt.core.client.GWT
import com.google.gwt.core.client.RunAsyncCallback
import de.scheidgen.xraw.util.Async.Promise
import de.scheidgen.xraw.util.Async.StarJoin
import de.scheidgen.xraw.util.Async.ThreeJoin
import de.scheidgen.xraw.util.Async.TwoJoin
import java.util.List
import java.util.logging.Logger
import org.eclipse.xtend.lib.annotations.Accessors

class Async {

	static val log = Logger.getLogger(Async.name)
	
	public static def void run(()=>void action) {
		GWT.runAsync(new RunAsyncCallback {			
			override onFailure(Throwable reason) {
				log.warning("Failure loading runAsync code.")	
			}
			
			override onSuccess() {
				action.apply()
			}			
		})
	}
	
	public static def <T> Promise<T> truePromise(T value) {
		promise[it.resolve(value)]
	}
	
	public static def <T> Promise<T> promise((Promise<T>)=>void keep) {
		new Promise<T>() {			
			override protected run() {
				keep.apply(this)
			}			
		}		
	}
	
	public static def <T> Defered<T> defer() {
		new Defered<T>()	
	}
	
	public static def <T,R,S> Promise<T> join(Promise<R> one, Promise<S> two, (R,S)=>T join) {
		return new TwoJoin<T,R,S>(one, two) {		
			override protected join(R one, S two) {
				join.apply(one, two)
			}			
		}.promise
	}
	
	public static def <T,Q,R,S> Promise<T> join(Promise<Q> zero, Promise<R> one, Promise<S> two, (Q,R,S)=>T join) {
		return new ThreeJoin<T,Q,R,S>(zero, one, two) {		
			override protected join(Q zero, R one, S two) {
				join.apply(zero, one, two)
			}			
		}.promise
	}
	
	public static def <T> Promise<T> joinAll(Iterable<Promise<?>> promises, (Iterable<?>)=>T join) {
		return new StarJoin<T>(promises) {			
			override protected join(Iterable<?> values) {
				join.apply(values)
			}			
		}.promise
	}
	
	static abstract class StarJoin<T> {
		val Iterable<Promise<?>> promises
		val Defered<T> defered = Async.defer
		var applied = false
		
		new(Iterable<Promise<?>> promises) {
			this.promises = promises
			promises.forEach[then[applyJoin]] // thats not right ...
		}		
		
		private def applyJoin() {
			if (promises.forall[state != Promise.State.running] && !applied) {
				applied = true
				if (promises.exists[state == Promise.State.rejected]) {
					defered.reject(promises.findFirst[cause != null]?.cause)
				} else {
					defered.resolve(join(promises.map[value]))	
				}				
			}
		}
		
		public def Promise<T> promise() {			
			defered.promise
		}
		
		abstract protected def T join(Iterable<?> values)
	}
	
	static abstract class TwoJoin<T,R,S> extends StarJoin<T> {			
		new(Promise<R> one, Promise<S> two) {
			super(#[one, two])
		}
		
		override protected join(Iterable<?> values) {
			val iterator = values.iterator
			join(iterator.next as R, iterator.next as S)
		}
		
		abstract protected def T join(R one, S two)
	}
	
	static abstract class ThreeJoin<T,Q,R,S> extends StarJoin<T> {			
		new(Promise<Q> zero, Promise<R> one, Promise<S> two) {
			super(#[zero, one, two])
		}
		
		override protected join(Iterable<?> values) {
			val iterator = values.iterator
			join(iterator.next as Q, iterator.next as R, iterator.next as S)
		}
		
		abstract protected def T join(Q zero, R one, S two)
	}
	
	/**
	 * Capsulates a data object that will be available later. Clients
	 * that need this data can register callbacks that will be executed
	 * once the data is available.
	 */
	static abstract class AsyncData<T> {
		var T data = null
		val List<(T)=>void> afterActions = newArrayList

		private new() {
			aquire[
				this.data = it
				for (action : afterActions) {
					action.apply(data)
				}
			]
		}
		
		abstract protected def void aquire((T)=>void result);

		private def available() {
			return data != null
		}

		/** 
		 * The given callback is executed as soon as the data is available.
		 */
		def void use((T)=>void action) {
			if (available) {
				action.apply(data)
			} else {
				afterActions += action
			}
		}
	}
	
	abstract static class Promise<T> {
		enum State { resolved, rejected, running}
		
		@Accessors(PUBLIC_GETTER) private var T value = null
		@Accessors(PUBLIC_GETTER) private var Throwable cause = null	
		@Accessors(PUBLIC_GETTER) private var state = State.running
		
		val List<(Promise<T>)=>void> actions = newArrayList
		
		private new() { run }
		
		synchronized def void resolve(T result) {
			value = result
			state = State.resolved
			apply
		}
		
		synchronized def void reject(Throwable cause) {
			state = State.rejected
			this.cause = cause
			apply
		}
		
		private def apply() {
			if (state != State.running) {
				for (action: actions) {
					action.apply(this)
				}
				actions.clear
			}
		}
		
		/**
		 * Given callback is executed once the promise is resolved or rejected.
		 */
		synchronized def void then((Promise<T>)=>void action) {
			if (state != State.running) {
				action.apply(this)
			} else {
				actions += action	
			}			
		}
		
		/**
		 * Allows to extend the promise with a new promise, once this promise is resolved.
		 * The new promise will be rejected if this promise or the follow up promise is rejected.
		 */
		def <R> Promise<R> further((T)=>Promise<R> action) {
			val defer = Async.defer	
			this.then[oldPromise|
				if (oldPromise.state == State.rejected) {
					defer.reject(oldPromise.cause)
				} else if (oldPromise.state == State.resolved) {
					val basePromise = action.apply(oldPromise.value)
					basePromise.then[
						if (basePromise.state == State.rejected) {
							defer.reject(basePromise.cause)
						} else if (basePromise.state == State.resolved) {
							defer.resolve(basePromise.value)		
						} else {
							throw new RuntimeException("Unreachable")
						}
					]
					
				} else {
					throw new RuntimeException("Unreachable")
				}
			]			
			defer.promise
		}
		
		def <R> Promise<R> furtherPromise((T)=>R action) {
			val defer = Async.defer	
			this.then[oldPromise|
				if (oldPromise.state == State.rejected) {
					defer.reject(oldPromise.cause)
				} else if (oldPromise.state == State.resolved) {
					defer.resolve(action.apply(oldPromise.value))
				} else {
					throw new RuntimeException("Unreachable")
				}
			]			
			defer.promise
		}
		
		def Promise<T> onResolve((T)=>void action) {
			then[if (state == State.resolved) action.apply(value)]
			this			
		} 
		
		def Promise<T> onReject((Throwable)=>void action) {
			then[if (state == State.rejected) action.apply(cause)]
			this
		}
		
		protected abstract def void run()
	}
	
	static class Defered<T> {
		val promise = new Promise<T> {			
			override protected run() {}			
		}
		
		def Promise<T> promise() {
			return promise
		}
		
		def void resolve(T result) {
			promise.resolve(result)
		}
		
		def void reject(Throwable cause) {
			promise.reject(cause)
		}
	}
	
	abstract static class AsyncIterator<T,P> {
	
		abstract protected def Promise<P> nextPage(P currentPage)
		abstract protected def Iterable<T> items(P page)
		
		var List<T> data = newArrayList
		var P currentPage = null
		
		public def Promise<Iterable<T>> promise(int ammount) {
			Async.promise[promise|
				fillData(ammount).then[
					if (data.size < ammount) {
						val result = data
						data = newArrayList
						promise.resolve(result)
					} else {
						val result = data.subList(0, ammount)
						data = data.subList(ammount, data.size).toList
						promise.resolve(result)					
					}
				]				
			]
		}	
		
		private def Promise<Void> fillData(int ammount) {
			val defered = Async.defer			
			if (data.size >= ammount) {
				defered.resolve(null)
			} else {
				nextPage(currentPage).then[
					if (state == Promise.State.rejected) {
						defered.resolve(null)
					} else {
						val values = value.items
						if (values.empty) {
							defered.resolve(null)
						} else {
							currentPage = value
							data.addAll(values)
							fillData(ammount).then[
								defered.resolve(null)
							]							
						}	
					}
				]
			}
			defered.promise
		}	
	}
}



