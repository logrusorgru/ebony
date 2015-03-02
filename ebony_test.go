package ebony

import "testing"

// basic suit

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
	x := "x"
	tr := New()
	tr.Set(0, x)
	if tr.root.id != 0 {
		t.Errorf("[set] wrong id, expected 0, got %d", tr.root.id)
	}
	switch v := tr.root.value.(type) {
	case string:
		if v != x {
			t.Errorf("[set] wrong returned value, expected '%s', got '%s'", x, v)
		}
	default:
		t.Errorf("[set] wrong type of returned value, expected 'string', got '%T'", v)
	}
	if tr.count != 1 {
		t.Errorf("[set] wrong count, expected 1, got %d", tr.count)
	}
}

func TestDel(t *testing.T) {
	x := "x"
	tr := New()
	tr.Set(0, x)
	tr.Del(0)
	if tr.count != 0 {
		t.Errorf("[del] wrong count after del, expected 0, got %d", tr.count)
	}
	if tr.root != sentinel {
		t.Error("[del] wrong tree state after del")
	}
}

func TestGet(t *testing.T) {
	x := "x"
	tr := New()
	tr.Set(0, x)
	val := tr.Get(0)
	switch v := val.(type) {
	case string:
		if v != x {
			t.Errorf("[get] wrong returned value, expected 'x', got '%s'", v)
		}
	default:
		t.Errorf("[get] wrong type of returned value, expected 'string', got '%T'", v)
	}
	if tr.count != 1 {
		t.Errorf("[get] wrong count, expected 1, got %d", tr.count)
	}
	if v := tr.Get(579); v != nil {
		t.Errorf("[get] wrong returned value, expected nil, got '%v'", v)
	}
	if tr.count != 1 {
		t.Errorf("[get] wrong count, expected 1, got %d", tr.count)
	}
}

func TestExist(t *testing.T) {
	x := "x"
	tr := New()
	tr.Set(0, x)
	val := tr.Exist(0)
	if !val {
		t.Error("[exist] existing is not exist")
	}
	val = tr.Exist(12)
	if val {
		t.Error("[exist] not existing is exist")
	}
}

func TestCount(t *testing.T) {
	x := "x"
	tr := New()
	if tr.Count() != 0 {
		t.Errorf("[count] wrong count, expected 0, got %d", tr.Count())
	}
	tr.Set(0, x)
	if tr.Count() != 1 {
		t.Errorf("[count] wrong count, expected 1, got %d", tr.Count())
	}
	tr.Set(1, x)
	if tr.Count() != 2 {
		t.Errorf("[count] wrong count, expected 2, got %d", tr.Count())
	}
	tr.Del(1)
	if tr.Count() != 1 {
		t.Errorf("[count] wrong count, expected 1, got %d", tr.Count())
	}
	tr.Del(0)
	if tr.Count() != 0 {
		t.Errorf("[count] wrong count, expected 0, got %d", tr.Count())
	}
}

func TestMove(t *testing.T) {
	x := "x"
	tr := New()
	tr.Set(0, x)
	tr.Move(0, 1)
	val := tr.Get(1)
	switch v := val.(type) {
	case string:
		if v != x {
			t.Errorf("[move] wrong returned value, expected '%s', got '%s'", x, v)
		}
	default:
		t.Errorf("[move] wrong type of returned value, expected 'string', got '%T'", v)
	}
	if tr.count != 1 {
		t.Errorf("[move] wrong count, expected 0, got %d", tr.count)
	}
}

func TestFlush(t *testing.T) {
	tr := New()
	tr.Set(0, "x")
	tr.Set(1, "y")
	tr.Set(2, "z")
	tr.Flush()
	if tr.count != 0 {
		t.Error("[flush] count != 0")
	}
	if tr.root != sentinel {
		t.Error("[flush] root != sentinel")
	}
}

func TestMax(t *testing.T) {
	max := "max"
	maxi := uint(6)
	tr := New()
	tr.Set(0, "x")
	tr.Set(1, "y")
	tr.Set(2, "z")
	tr.Set(maxi, max)
	tr.Set(3, "m")
	tr.Set(4, "n")
	tr.Set(5, "o")
	i, val := tr.Max()
	if i != maxi {
		t.Errorf("[max] wrong index of min, expected %d, got %d", maxi, i)
	}
	switch v := val.(type) {
	case string:
		if v != max {
			t.Errorf("[max] wrong returned value, expected '%s', got '%s'", max, v)
		}
	default:
		t.Errorf("[max] wrong type of returned value, expected 'string', got '%T'", v)
	}
}

func TestMin(t *testing.T) {
	min := "min"
	mini := uint(0)
	tr := New()
	tr.Set(1, "x")
	tr.Set(2, "y")
	tr.Set(3, "z")
	tr.Set(mini, min)
	tr.Set(4, "m")
	tr.Set(5, "n")
	tr.Set(6, "o")
	i, val := tr.Min()
	if i != mini {
		t.Errorf("[min] wrong index of min, expected %d, got %d", mini, i)
	}
	switch v := val.(type) {
	case string:
		if v != min {
			t.Errorf("[min] wrong returned value, expected '%s', got '%s'", min, v)
		}
	default:
		t.Errorf("[min] wrong type of returned value, expected 'string', got '%T'", v)
	}
}

/*
func TestRange(t *testing.T) {
	tr := New()
	tr.Set(0, "x")
	tr.Set(1, "y")
	tr.Set(2, "z")
	tr.Set(3, "m")
	tr.Set(4, "n")
	valsg := tr.Range(1, 3)
	fmt.Printf("%# v\n", pretty.Formatter(tr))
	fmt.Printf("%# v\n", pretty.Formatter(valsg))
	valse := []string{"y", "z", "m"}
	for i := 0; i < len(valse) && i < len(valsg); i++ {
		x := valse[i]
		r := valsg[i]
		switch v := r.(type) {
		case string:
			if v != x {
				t.Errorf("[range] wrong returned value, expected '%s', got '%s'", x, v)
			}
		default:
			t.Errorf("[range] wrong type of returned value, expected 'string', got '%T'", v)
		}
	}
	if len(valse) != len(valsg) {
		t.Errorf("[range] wrong number of values, expected %d, got %d", len(valse), len(valsg))
	}

}
*/
