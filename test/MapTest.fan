
class MapTest : Test
{
  Void testTrivialPositive()
  {
    map := ConstHashMap.empty
    map = map["foo"] = "bar"
    verifyEq(map.keys.toList, Obj?["foo"])
    verifyEq(map["foo"], "bar")
    verify(map.containsKey("foo"))
  }
  
  Void test1()
  {
    count := 100
    map := ConstHashMap.empty
    count.times
    {
      map = map[it] = it.toStr
      verifyEq(map.size, it+1)
    }
    count.times
    {
      verifyEq(map[it], it.toStr)
    }
    verifyEq(map.keys.toList.sort, Obj?[,].addAll((0..<count).toList))
  }
  
  Void testCollision()
  {
    map := ConstHashMap.empty
    c1 := Collider(2, 2)
    c2 := Collider(4, 0)
    c3 := Collider(3, 1)
    map = map[c1] = "foo"
    map = map[c2] = "bar"
    map = map[c3] = "baz"
    verifyEq(map[c1], "foo")
    verifyEq(map[c2], "bar")
    verifyEq(map[c3], "baz")
  }
}

internal const class Collider
{
  const Int a
  const Int b
  new make(Int a, Int b)
  {
    this.a = a
    this.b = b
  }
  
  override Str toStr() {"$a + $b"}
  override Int hash() { a + b }
}
