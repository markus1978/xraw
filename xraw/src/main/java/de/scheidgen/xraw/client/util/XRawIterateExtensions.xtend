package de.scheidgen.xraw.client.util

import com.google.common.collect.AbstractIterator
import com.google.common.collect.FluentIterable
import de.scheidgen.xraw.client.util.XRawIterateExtensions.Result
import java.util.ArrayList
import java.util.Iterator

class XRawIterateExtensions {
	private static class Result<T> implements Iterator<T> {		
		var elements = new ArrayList<T>
		var iterables = new ArrayList<Iterable<T>>
		
		synchronized def void add(T element) {
			elements.add(element)
		}
		
		synchronized def void addAll(Iterable<T> iterable) {
			iterables.add(iterable)
		}		
		
		synchronized def reset() {
			elements.clear
			iterables.clear
			iterables.add(elements)
			iterator = null
		}
		
		var Iterator<T> iterator = null
		
		override hasNext() {
			if (iterator == null) {
				iterator = iterables.flatten.iterator				
			}
			return iterator.hasNext	
		}
		
		override next() {
			if (iterator == null) {
				iterator = iterables.flatten.iterator				
			}
			return iterator.next
		}
		
		override remove() {
			throw new UnsupportedOperationException("Not supported, iterable is immutable.")
		}		
	}
	
	private static def <E,T> Iterable<T> standardIterate(Iterable<E> source, Functions.Function2<E, Result<T>, Void> function) {
		return new FluentIterable<T>() {			
			override iterator() {
				val Iterator<E> sourceIterator = source.iterator
				val nextResult = new Result<T>
				return new AbstractIterator<T>() {					
					override protected computeNext() {
						if (nextResult.hasNext) {
							return nextResult.next
						} else {
							while (sourceIterator.hasNext) {
								val next = sourceIterator.next
								nextResult.reset
								function.apply(next, nextResult)
								if (nextResult.hasNext) {
									return nextResult.next
								}								
							}
							return endOfData
						}												
					}					
				}
			}			
		}
	}
	
	private static def <E,T> Iterable<T> concurrentIterate(Iterable<E> source, Functions.Function2<E, Result<T>, Void> function) {
		// TODO implement with Async
//		val result = new Result<T>
//		val futures = source.map[value|
//			return CompletableFuture::runAsync[
//				function.apply(value, result)
//			]
//		]
//		CompletableFuture::allOf(futures.toList.toArray(#{})).join				
//		return result.elements
		return null;				
	}
	
	public static def standard() {
		return new XRawIterateExtensions[source, function|
			return standardIterate(source, function)			
		]
	}
	
	public static def concurrent() {
		return new XRawIterateExtensions[source, function|
			return concurrentIterate(source, function)			
		]
	}
	
	val (Iterable, Functions.Function2)=>Iterable untypedIterate
	
	private new((Iterable, Functions.Function2)=>Iterable untypedIterate) {
		this.untypedIterate = untypedIterate
	}
	
	def <E,T> Iterable<T> iterate(Iterable<E> source, Functions.Function2<E, Result<T>, Void> function) {
		return untypedIterate.apply(source, function)
	}
	
	def <E, T> collect(Iterable<E> source, Functions.Function1<E,T> function) {
		return source.iterate[element, result |
			result.add(function.apply(element))
			return null
		]
	}
	
	def <E, T> collectAll(Iterable<E> source, Functions.Function1<E, ? extends Iterable<T>> function) {
		return source.iterate[element, result |
			result.addAll(function.apply(element))
			return null
		]
	}
	
	def <E> select(Iterable<E> source, Functions.Function1<E,Boolean> function) {
		return source.iterate[element, result |
			if (function.apply(element)) {
				result.add(element)
			}
			return null
		]
	}
	
	def <E> Iterable<E> closure(Iterable<E> source, Functions.Function1<E, Iterable<E>> function) {
		return source.iterate[element, result |
			result.add(element)
			result.addAll(function.apply(element).closure(function))
			return null
		]
	}
	
	def <E> Iterable<E> closure(E source, Functions.Function1<E, Iterable<E>> function) {
		return #{source}.closure(function)	
	}
	
	def <E> void foreach(Iterable<E> source, Functions.Function1<E, Void> function) {
		source.iterate[element, result|function.apply(element)]
	}
}