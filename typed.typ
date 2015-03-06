/*

For example:
- use own struct as index type
- not use value type
- coutner type = int
================================================================================

Content of "types.typ"
--------------------------------------------------------------------------------
type Index struct {
	Weight int
	Value string
}

func less(a, b *Index) bool {
	return a.Weight < b.Weight
}

func equal(a, b *Index) bool {
	return a.Weight == b.Weight
}
--------------------------------------------------------------------------------

Content of this file
--------------------------------------------------------------------------------
#define IndexType *Index
#define NilIndexType nil
//#define ValueType

// should be a number
#define CountType int

#define Less(a,b) less(a, b)
#define Grater(a,b) less(b, a)

#define Equal(a,b) equal(a, b)

#define LessOrEqual(a,b) less(a, b) || equal(a, b)
#define GraterOrEqual(a,b) less(b, a) || equal(a, b)

// for basic test suit
#define NewIndexObject &Index{}
#define NewIncrementIndexObject(a) &Index{Weight: a.Weight + 1}

// required for basic test suit only if ValueType Defined
//#define NewValueObject 0
//#define NewIncrementValueObject(a) a + 1
--------------------------------------------------------------------------------

Done =)

================================================================================

*/


// types
#define IndexType uint
#define NilIndexType 0

#define ValueType interface{}
#define NilValueType nil

// type of counter
#define CountType uint

// cmp
#define Less(a,b) a < b
#define Grater(a,b) a > b

#define Equal(a,b) a == b

#define LessOrEqual(a,b) a <= b
#define GraterOrEqual(a,b) a >= b

// test

// required for basic test suit
#define NewIndexObject IndexType(0)
#define NewIncrementIndexObject(a) a + 1

// required for basic test suit only if ValueType defined
#define NewValueObject "a"
#define NewIncrementValueObject(a) "a" + "a"
