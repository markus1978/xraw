package de.scheidgen.xraw.util

import static extension de.scheidgen.xraw.util.XRawIterableExtensions.*
import org.junit.Test
import static org.junit.Assert.*

class XRawIterableExtensionsTests {
	
	@Test
	public def void splitTest() {
		val splits = (0..99).split(10)
		assertSame(10, splits.size)
		for(split: splits) {
			assertSame(10, split.size)
		}
	}
	
	@Test
	public def void overSizeSplitTest() {
		val splits = (0..49).split(100)
		assertSame(1, splits.size)
		for(split: splits) {
			assertSame(50, split.size)
		}
	}
	
	@Test
	public def void emptySplitTest() {
		val splits = newArrayList().split(10)
		assertSame(1, splits.size)
		for(split: splits) {
			assertSame(0, split.size)
		}
	}
	
	@Test
	public def void firstTest() {
		assertSame(0, (0..1).first)
	}
	
	@Test
	public def void emtpyFirstTest() {
		assertSame(null, newArrayList.first)
	}
	
	@Test
	public def void firstIntTest() {
		assertSame(10, (0..100).first(10).size)
	}
	
	@Test
	public def void emptyFirstIntTest() {
		assertSame(0, newArrayList.first(10).size)
	}
}