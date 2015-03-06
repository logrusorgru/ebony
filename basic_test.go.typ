package ebony

import "testing"

#include "typed.typ"

func TestNew(t *testing.T) {
	tr := New()
	if tr.count != 0 {
		t.Error("[new] count != 0")
	}
	if tr.root != sentinel {
		t.Error("[new] root != sentinel")
	}
}

func TestSet(t *testing.T) {
	i := NewIndexObject
#ifdef ValueType
	x := NewValueObject
#endif
	tr := New()
#ifdef ValueType
	tr.Set(i, x)
#else
	tr.Set(i)
#endif
	if tr.root.id != i {
		t.Errorf("[set] wrong id, expected '%v', got '%v'", i, tr.root.id)
	}
#ifdef ValueType
	if v := tr.root.value; v != x {
		t.Errorf("[set] wrong setted value, expected '%v', got '%v'", x, v)
	}
#endif
}

func TestDel(t *testing.T) {
	i := NewIndexObject
#ifdef ValueType
	x := NewValueObject
#endif
	tr := New()
#ifdef ValueType
	tr.Set(i, x)
#else
	tr.Set(i)
#endif
	tr.Del(i)
	if tr.count != 0 {
		t.Errorf("[del] wrong count after del, expected 0, got %d", tr.count)
	}
	if tr.root != sentinel {
		t.Error("[del] wrong tree state after del")
	}
}

func TestGet(t *testing.T) {
	i := NewIndexObject
#ifdef ValueType
	x := NewValueObject
#endif
	tr := New()
#ifdef ValueType
	tr.Set(i, x)
#else
	tr.Set(i)
#endif
#ifdef ValueType
	if v := tr.Get(i); v != x {
		t.Errorf("[get] wrong returned value, expected '%v', got '%v'", v, x)
#else
	if v := tr.Get(i); v != i {
		t.Errorf("[get] wrong returned index, expected '%v', got '%v'", i, v)
#endif
	}
	j := NewIncrementIndexObject(i)
#ifdef ValueType
	if v := tr.Get(j); v != NilValueType {
		t.Errorf("[get] wrong returned value, expected '%v', got '%v'", NilValueType, v)
#else
	if v := tr.Get(j); v != NilIndexType {
		t.Errorf("[get] wrong returned index, expected '%v', got '%v'", NilIndexType, v)
#endif
	}
	if tr.count != 1 {
		t.Errorf("[get] wrong count, expected 1, got %d", tr.count)
	}
}

func TestExist(t *testing.T) {
	i := NewIndexObject
#ifdef ValueType
	x := NewValueObject
#endif
	tr := New()
#ifdef ValueType
	tr.Set(i, x)
#else
	tr.Set(i)
#endif
	if !tr.Exist(i) {
		t.Errorf("[exist] value should exist")
	}
	j := NewIncrementIndexObject(i)
	if tr.Exist(j) {
		t.Errorf("[exist] value shouldn't exist")
	}
}

func TestCount(t *testing.T) {
	tr := New()
	if tr.Count() != 0 {
		t.Errorf("[count] wrong count, expected 0, got %d", tr.Count())
	}
	i := NewIndexObject
#ifdef ValueType
	x := NewValueObject
	tr.Set(i, x)
#else
	tr.Set(i)
#endif
	if tr.Count() != 1 {
		t.Errorf("[count] wrong count, expected 1, got %d", tr.Count())
	}
	j := NewIncrementIndexObject(i)
#ifdef ValueType
	tr.Set(j, x)
#else
	tr.Set(j)
#endif
	if tr.Count() != 2 {
		t.Errorf("[count] wrong count, expected 2, got %d", tr.Count())
	}
	tr.Del(j)
	if tr.Count() != 1 {
		t.Errorf("[count] wrong count, expected 1, got %d", tr.Count())
	}
	tr.Del(i)
	if tr.Count() != 0 {
		t.Errorf("[count] wrong count, expected 0, got %d", tr.Count())
	}
}

func TestMove(t *testing.T) {
	tr := New()
	i := NewIndexObject
#ifdef ValueType
	x := NewValueObject
	tr.Set(i, x)
#else
	tr.Set(i)
#endif
	j := NewIncrementIndexObject(i)
	tr.Move(i, j)
#ifdef ValueType
	if v := tr.Get(j); v != x {
		t.Errorf("[move] wrong returned value, expected '%v', got '%v'", x, v)
	}
#else
	if v := tr.Get(j); v != j {
		t.Errorf("[move] wrong returned index, expected '%v', got '%v'", j, v)
	}
#endif
#ifdef ValueType
	if v := tr.Get(i); v != NilValueType {
		t.Errorf("[move] wrong returned value, expected '%v', got '%v'", NilValueType, v)
	}
#else
	if v := tr.Get(i); v != NilIndexType {
		t.Errorf("[move] wrong returned index, expected '%v', got '%v'", NilIndexType, v)
	}
#endif
	if tr.count != 1 {
		t.Errorf("[move] wrong count, expected 1, got %d", tr.count)
	}
}

func TestFlush(t *testing.T) {
	tr := New()
	i := NewIndexObject
#ifdef ValueType
	x := NewValueObject
	tr.Set(i, x)
#else
	tr.Set(i)
#endif
	j := NewIncrementIndexObject(i)
#ifdef ValueType
	tr.Set(j, x)
#else
	tr.Set(j)
#endif
	tr.Flush()
	if tr.count != 0 {
		t.Error("[flush] count != 0")
	}
	if tr.root != sentinel {
		t.Error("[flush] root != sentinel")
	}
}

func TestMax(t *testing.T) {
	tr := New()
	i := NewIndexObject
#ifdef ValueType
	x := NewValueObject
	tr.Set(i, x)
#else
	tr.Set(i)
#endif
	j := NewIncrementIndexObject(i)
#ifdef ValueType
	y := NewIncrementValueObject(x)
	tr.Set(j, y)
#else
	tr.Set(j)
#endif
#ifdef ValueType
	indx, val := tr.Max();
	if indx != j {
		t.Errorf("[max] wrong index of max, expected %d, got %d", j, indx)
	}
	if val != y {
		t.Errorf("[max] wrong value of max, expected %d, got %d", y, val)
	}
#else
	indx := tr.Max();
	if indx != j {
		t.Errorf("[max] wrong index of max, expected %d, got %d", j, indx)
	}
#endif
}

func TestMin(t *testing.T) {
	tr := New()
	i := NewIndexObject
#ifdef ValueType
	x := NewValueObject
	tr.Set(i, x)
#else
	tr.Set(i)
#endif
	j := NewIncrementIndexObject(i)
#ifdef ValueType
	y := NewIncrementValueObject(x)
	tr.Set(j, y)
#else
	tr.Set(j)
#endif
#ifdef ValueType
	indx, val := tr.Min();
	if indx != i {
		t.Errorf("[min] wrong index of min, expected %d, got %d", i, indx)
	}
	if val != x {
		t.Errorf("[min] wrong value of min, expected %d, got %d", x, val)
	}
#else
	indx := tr.Min();
	if indx != i {
		t.Errorf("[min] wrong index of min, expected %d, got %d", i, indx)
	}
#endif
}
