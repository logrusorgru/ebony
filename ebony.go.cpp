// rb-tree with uint index, not thread safe
//
// Usage notes
//
// A nil is the value. Use Del() to delete value. But if value doesn't exist
// method Get() returns nil. You can to use struct{} as an emty value to
// avoid confusions. Walk() doesn't support Tree manipulations, yet (Set()
// and Del() ops.).
//
//    If you want to lookup the tree much more than change it,
//    take a look at LLRB (if memory usage are critical)
//
//    Read http://www.read.seas.harvard.edu/~kohler/notes/llrb.html
//    Source https://github.com/petar/GoLLRB
package ebony

import (
	"errors"
	"runtime"
)

#define IndexType uint
#define ValueType interface{}
#define CountType uint

#define Less(a,b) a < b
#define Grater(a,b) a > b

#define Equal(a,b) a == b

#define LessOrEqual(a,b) a <= b
#define GraterOrEqual(a,b) a >= b

const (
	red   = true
	black = false
)

type node struct {
	left   *node
	right  *node
	parent *node
	color  bool
	id     IndexType
	value  ValueType
}

var sentinel = &node{nil, nil, nil, black, 0, nil}

func init() {
	sentinel.left, sentinel.right = sentinel, sentinel
}

type Tree struct {
	root  *node
	count CountType
}

func (t *Tree) rotateLeft(x *node) {
	y := x.right
	x.right = y.left
	if y.left != sentinel {
		y.left.parent = x
	}
	if y != sentinel {
		y.parent = x.parent
	}
	if x.parent != nil {
		if x == x.parent.left {
			x.parent.left = y
		} else {
			x.parent.right = y
		}
	} else {
		t.root = y
	}
	y.left = x
	if x != sentinel {
		x.parent = y
	}
}

func (t *Tree) rotateRight(x *node) {
	y := x.left
	x.left = y.right
	if y.right != sentinel {
		y.right.parent = x
	}
	if y != sentinel {
		y.parent = x.parent
	}
	if x.parent != nil {
		if x == x.parent.right {
			x.parent.right = y
		} else {
			x.parent.left = y
		}
	} else {
		t.root = y
	}
	y.right = x
	if x != sentinel {
		x.parent = y
	}
}

func (t *Tree) insertFixup(x *node) {
	for x != t.root && x.parent.color == red {
		if x.parent == x.parent.parent.left {
			y := x.parent.parent.right
			if y.color == red {
				x.parent.color = black
				y.color = black
				x.parent.parent.color = red
				x = x.parent.parent
			} else {
				if x == x.parent.right {
					x = x.parent
					t.rotateLeft(x)
				}
				x.parent.color = black
				x.parent.parent.color = red
				t.rotateRight(x.parent.parent)
			}
		} else {
			y := x.parent.parent.left
			if y.color == red {
				x.parent.color = black
				y.color = black
				x.parent.parent.color = red
				x = x.parent.parent
			} else {
				if x == x.parent.left {
					x = x.parent
					t.rotateRight(x)
				}
				x.parent.color = black
				x.parent.parent.color = red
				t.rotateLeft(x.parent.parent)
			}
		}
	}
	t.root.color = black
}

func (t *Tree) insertNode(id IndexType, value ValueType) {
	current := t.root
	var parent *node
	for current != sentinel {
		if Equal(id, current.id) {
			current.value = value
			return
		}
		parent = current
		if Less(id, current.id) {
			current = current.left
		} else {
			current = current.right
		}
	}
	x := &node{
		value:  value,
		parent: parent,
		left:   sentinel,
		right:  sentinel,
		color:  red,
		id:     id,
	}
	if parent != nil {
		if Less(id, parent.id) {
			parent.left = x
		} else {
			parent.right = x
		}
	} else {
		t.root = x
	}
	t.insertFixup(x)
	t.count++
}

func (t *Tree) deleteFixup(x *node) {
	for x != t.root && x.color == black {
		if x == x.parent.left {
			w := x.parent.right
			if w.color == red {
				w.color = black
				x.parent.color = red
				t.rotateLeft(x.parent)
				w = x.parent.right
			}
			if w.left.color == black && w.right.color == black {
				w.color = red
				x = x.parent
			} else {
				if w.right.color == black {
					w.left.color = black
					w.color = red
					t.rotateRight(w)
					w = x.parent.right
				}
				w.color = x.parent.color
				x.parent.color = black
				w.right.color = black
				t.rotateLeft(x.parent)
				x = t.root
			}
		} else {
			w := x.parent.left
			if w.color == red {
				w.color = black
				x.parent.color = red
				t.rotateRight(x.parent)
				w = x.parent.left
			}
			if w.right.color == black && w.left.color == black {
				w.color = red
				x = x.parent
			} else {
				if w.left.color == black {
					w.right.color = black
					w.color = red
					t.rotateLeft(w)
					w = x.parent.left
				}
				w.color = x.parent.color
				x.parent.color = black
				w.left.color = black
				t.rotateRight(x.parent)
				x = t.root
			}
		}
	}
	x.color = black
}

// silent
func (t *Tree) deleteNode(z *node) {
	var x, y *node
	if z == nil || z == sentinel {
		return
	}
	if z.left == sentinel || z.right == sentinel {
		y = z
	} else {
		y = z.right
		for y.left != sentinel {
			y = y.left
		}
	}
	if y.left != sentinel {
		x = y.left
	} else {
		x = y.right
	}
	x.parent = y.parent
	if y.parent != nil {
		if y == y.parent.left {
			y.parent.left = x
		} else {
			y.parent.right = x
		}
	} else {
		t.root = x
	}
	if y != z {
		z.id = y.id
		z.value = y.value
	}
	if y.color == black {
		t.deleteFixup(x)
	}
	t.count--
}

func (t *Tree) findNode(id IndexType) *node {
	current := t.root
	for current != sentinel {
		if Equal(id, current.id) {
			return current
		}
		if Less(id, current.id) {
			current = current.left
		} else {
			current = current.right
		}
	}
	return sentinel
}

func New() *Tree {
	return &Tree{
		root: sentinel,
	}
}

func (t *Tree) Set(id IndexType, value ValueType) {
	t.insertNode(id, value)
}

func (t *Tree) Del(id IndexType) {
	t.deleteNode(t.findNode(id))
}

func (t *Tree) Get(id IndexType) ValueType {
	return t.findNode(id).value
}

func (t *Tree) Exist(id IndexType) bool {
	return t.findNode(id) != sentinel
}

func (t *Tree) Count() CountType {
	return t.count
}

func (t *Tree) Move(oid, nid IndexType) {
	if n := t.findNode(oid); n != sentinel {
		t.insertNode(nid, n.value)
		t.deleteNode(n)
	}
}

func (t *Tree) Flush() *Tree {
	t.root = sentinel
	t.count = 0
	runtime.GC()
	return t
}

func (t *Tree) Max() (IndexType, ValueType) {
	current := t.root
	for current.right != sentinel {
		current = current.right
	}
	return current.id, current.value
}

func (t *Tree) Min() (IndexType, ValueType) {
	current := t.root
	for current.left != sentinel {
		current = current.left
	}
	return current.id, current.value
}

type Walker func(key IndexType, value ValueType) error

var Stop = errors.New("stop a walking")

func (n *node) walk_left(from, to IndexType, wl Walker) error {
	if Grater(n.id, from) {
		if n.left != sentinel {
			if err := n.left.walk_left(from, to, wl); err != nil {
				return err
			}
		}
	}
	if GraterOrEqual(n.id, from) && LessOrEqual(n.id, to) {
		if err := wl(n.id, n.value); err != nil {
			return err
		}
	}
	if Less(n.id, to) {
		if n.right != sentinel {
			if err := n.right.walk_left(from, to, wl); err != nil {
				return err
			}
		}
	}
	return nil
}

func (n *node) walk_right(from, to uint, wl Walker) error {
	if Less(n.id, from) {
		if n.right != sentinel {
			if err := n.right.walk_right(from, to, wl); err != nil {
				return err
			}
		}
	}
	if LessOrEqual(n.id, from) && GraterOrEqual(n.id, to) {
		if err := wl(n.id, n.value); err != nil {
			return err
		}
	}
	if Grater(n.id, to) {
		if n.left != sentinel {
			if err := n.left.walk_right(from, to, wl); err != nil {
				return err
			}
		}
	}
	return nil
}

func (t *Tree) Walk(from, to IndexType, wl Walker) error {
	if Equal(from, to) {
		node := t.findNode(from)
		if node != sentinel {
			return wl(node.id, node.value)
		}
		return nil
	} else if Less(from, to) {
		return t.root.walk_left(from, to, wl)
	} // else if to < from
	return t.root.walk_right(from, to, wl)
}

func (t *Tree) Range(from, to IndexType) []ValueType {
	vals := []ValueType{}
	wl := func(_ IndexType, value ValueType) error {
		vals = append(vals, value)
		return nil
	}
	t.Walk(from, to, wl)
	if len(vals) == 0 {
		return nil
	}
	return vals
}
