package de.scheidgen.xraw.util;

import de.scheidgen.xraw.util.XRawIterableExtensions;
import java.util.ArrayList;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.junit.Assert;
import org.junit.Test;

@SuppressWarnings("all")
public class XRawIterableExtensionsTests {
  @Test
  public void splitTest() {
    IntegerRange _upTo = new IntegerRange(0, 99);
    final Iterable<Iterable<Integer>> splits = XRawIterableExtensions.<Integer>split(_upTo, 10);
    int _size = IterableExtensions.size(splits);
    Assert.assertSame(Integer.valueOf(10), Integer.valueOf(_size));
    for (final Iterable<Integer> split : splits) {
      int _size_1 = IterableExtensions.size(split);
      Assert.assertSame(Integer.valueOf(10), Integer.valueOf(_size_1));
    }
  }
  
  @Test
  public void overSizeSplitTest() {
    IntegerRange _upTo = new IntegerRange(0, 49);
    final Iterable<Iterable<Integer>> splits = XRawIterableExtensions.<Integer>split(_upTo, 100);
    int _size = IterableExtensions.size(splits);
    Assert.assertSame(Integer.valueOf(1), Integer.valueOf(_size));
    for (final Iterable<Integer> split : splits) {
      int _size_1 = IterableExtensions.size(split);
      Assert.assertSame(Integer.valueOf(50), Integer.valueOf(_size_1));
    }
  }
  
  @Test
  public void emptySplitTest() {
    ArrayList<Object> _newArrayList = CollectionLiterals.<Object>newArrayList();
    final Iterable<Iterable<Object>> splits = XRawIterableExtensions.<Object>split(_newArrayList, 10);
    int _size = IterableExtensions.size(splits);
    Assert.assertSame(Integer.valueOf(1), Integer.valueOf(_size));
    for (final Iterable<Object> split : splits) {
      int _size_1 = IterableExtensions.size(split);
      Assert.assertSame(Integer.valueOf(0), Integer.valueOf(_size_1));
    }
  }
  
  @Test
  public void firstTest() {
    IntegerRange _upTo = new IntegerRange(0, 1);
    Integer _first = XRawIterableExtensions.<Integer>first(_upTo);
    Assert.assertSame(Integer.valueOf(0), _first);
  }
  
  @Test
  public void emtpyFirstTest() {
    ArrayList<Object> _newArrayList = CollectionLiterals.<Object>newArrayList();
    Object _first = XRawIterableExtensions.<Object>first(_newArrayList);
    Assert.assertSame(null, _first);
  }
  
  @Test
  public void firstIntTest() {
    IntegerRange _upTo = new IntegerRange(0, 100);
    Iterable<Integer> _first = XRawIterableExtensions.<Integer>first(_upTo, 10);
    int _size = IterableExtensions.size(_first);
    Assert.assertSame(Integer.valueOf(10), Integer.valueOf(_size));
  }
  
  @Test
  public void emptyFirstIntTest() {
    ArrayList<Object> _newArrayList = CollectionLiterals.<Object>newArrayList();
    Iterable<Object> _first = XRawIterableExtensions.<Object>first(_newArrayList, 10);
    int _size = IterableExtensions.size(_first);
    Assert.assertSame(Integer.valueOf(0), Integer.valueOf(_size));
  }
}
