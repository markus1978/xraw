package de.scheidgen.xraw.util

import com.google.gwt.core.client.GWT
import com.google.gwt.core.client.RunAsyncCallback
import de.scheidgen.xraw.util.Async.Promise
import java.util.Collection
import java.util.List
import java.util.logging.Logger
import org.eclipse.xtend.lib.annotations.Accessors

class Async {

	private static val log = Logger.getLogger(Async.name)	
	private static val Collection<Promise<?>> running = newHashSet
		
	public static def afterAll(()=>void callback) {
		Async.join(running.toList.toArray(#[])).then[callback.apply]
	}
	
	public static def rejectAll(Throwable reason) {
		running.toList.forEach[it.reject(reason)]
	}
	
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
	
	public static def <T> Promise<T> directPromise(T value) {
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
	
	public static def Promise<Void> join(Promise<?>... promises) {
		return new Join(newArrayList(promises)).promise
	}
	
	static class Join {
		val Iterable<Promise<?>> promises
		val Defered<Void> defered = Async.defer
		
		new(Iterable<Promise<?>> promises) {
			this.promises = promises
			promises.forEach[then[applyJoin]]
		}		
		
		private def applyJoin() {
			if (promises.forall[state != Promise.State.running]) {
				if (promises.exists[state == Promise.State.rejected]) {
					defered.reject(promises.findFirst[cause != null]?.cause)
				} else {
					defered.resolve(null)	
				}				
			}
		}
		
		public def Promise<Void> promise() {			
			defered.promise
		}
	}

	abstract static class Promise<T> {
		enum State { resolved, rejected, running}
		
		@Accessors(PUBLIC_GETTER) private var T value = null
		@Accessors(PUBLIC_GETTER) private var Throwable cause = null	
		@Accessors(PUBLIC_GETTER) private var state = State.running
		
		val List<(Promise<T>)=>void> actions = newArrayList
		
		private new() { 
			running += this
			run
		}
		
		synchronized def void resolve(T result) {
			if (state == State.running) {
				value = result
				state = State.resolved
				apply
				running -= this			
			} else {
				log.warning("Promise that was no longer running, was resolved (it was probably terminated by rejectAll)")
			}
		}
		
		synchronized def void reject(Throwable cause) {
			if (state == State.running) {
				state = State.rejected
				this.cause = cause
				apply
				running -= this	
			} else {
				log.warning("Promise that was no longer running, was resolved (it was probably terminated by rejectAll)")
			}
		}
		
		private def apply() {
			for (action: actions) {
				action.apply(this)
			}
			actions.clear
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
}



