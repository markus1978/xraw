package de.scheidgen.xraw.util

import com.google.common.collect.AbstractIterator
import com.google.common.collect.FluentIterable
import java.util.ArrayList
import java.util.Iterator

class XRawIterableExtensions {
	private static class Result<T> implements Iterator<T> {		
		var elements = new ArrayList<T>
		var iterables = new ArrayList<Iterable<T>>
		
		def void add(T element) {
			elements.add(element)
		}
		
		def void addAll(Iterable<T> iterable) {
			iterables.add(iterable)
		}		
		
		def reset() {
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
	
	private static def <E,T> Iterable<T> iterate(Iterable<E> source, Functions.Function2<E, Result<T>, Void> function) {
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
	
	static def <E, T> collect(Iterable<E> source, Functions.Function1<E,T> function) {
		return source.iterate[element, result |
			result.add(function.apply(element))
			return null
		]
	}
	
	static def <E, T> collectAll(Iterable<E> source, Functions.Function1<E, ? extends Iterable<T>> function) {
		return source.iterate[element, result |
			result.addAll(function.apply(element))
			return null
		]
	}
	
	static def <E> select(Iterable<E> source, Functions.Function1<E,Boolean> function) {
		return source.iterate[element, result |
			if (function.apply(element)) {
				result.add(element)
			}
			return null
		]
	}
	
	static def <E> Iterable<E> closure(Iterable<E> source, Functions.Function1<E, Iterable<E>> function) {
		return source.iterate[element, result |
			result.add(element)
			result.addAll(function.apply(element).closure(function))
			return null
		]
	}
	
	static def <E> Iterable<E> closure(E source, Functions.Function1<E, Iterable<E>> function) {
		return #{source}.closure(function)	
	}
	
	static def <E> Iterable<E> union(Iterable<? extends E> one, Iterable<? extends E> two) {
		val oneIterator = one.iterator
		val twoIterator = two.iterator
		return new FluentIterable<E>() {			
			override iterator() {
				return new AbstractIterator<E> {					
					override protected computeNext() {
						if (oneIterator.hasNext) {
							return oneIterator.next
						} else if (twoIterator.hasNext) {
							return twoIterator.next
						} else {
							return endOfData
						}
					}					
				}
			}			
		}
	}
	
	static def <E> sum(Iterable<E> source, Functions.Function1<E,Integer> function) {
		return source.fold(0)[sum, element | sum + function.apply(element)]
	}
	
	static def <E> max(Iterable<E> source, Functions.Function1<E,Integer> function) {
		return source.fold(Integer.MIN_VALUE)[max, element | 
			val value = function.apply(element)
			return if (value > max) value else max
		]
	}
	
	static def <E, T extends E> typeSelect(Iterable<E> source, Class<T> type) {
		return source.select[type.isAssignableFrom(it.class)].collect[it as T]		
	}

	static def <E> Iterable<Iterable<E>> split(Iterable<? extends E> iterable, int splitSize) {
		return new FluentIterable<Iterable<E>> {			
			override iterator() {
				val source = iterable.iterator
				return new AbstractIterator<Iterable<E>> {	
					var boolean empty = true								
					override protected computeNext() {
						if (source.hasNext) {
							empty = false
							val split = new ArrayList<E>(splitSize)
							var i = 0
							while (source.hasNext && i++ < splitSize) {
								split.add(source.next)
							}
							return split						
						} else {
							if (empty) {
								empty = false
								new ArrayList<E>(0)
							} else {
								return endOfData							
							}
						}
					}					
				}
			}						
		}
	}
	
	static def <E> Iterable<E> first(Iterable<E> iterable, int firstSize) {
		val sourceIterator = iterable.iterator
		return new FluentIterable<E> {
			var i = 0			
			override iterator() {
				return new AbstractIterator<E> {					
					override protected computeNext() {
						if (sourceIterator.hasNext && i++ < firstSize) {
							return sourceIterator.next
						} else {
							return endOfData
						}
					}					
				}
			}			
		}
	}
	
	static def <E> E first(Iterable<E> iterable) {
		val iterator = iterable.iterator
		if (iterator.hasNext) {
			return iterator.next
	 	} else {
	 		return null
	 	} 
	}
}