
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
    c3 := Collider(300000, -299996)
    map = map[c1] = "foo"
    map = map[c2] = "bar"
    map = map[c3] = "baz"
    verifyEq(map[c1], "foo")
    verifyEq(map[c2], "bar")
    verifyEq(map[c3], "baz")
    
    map = map.remove(c1) { verifyEq(it, "foo") }
    verifyEq(map.size, 2)
    map = map.remove(c2) { verifyEq(it, "bar") }
    verifyEq(map.size, 1)
    map = map.remove(c3) { verifyEq(it, "baz") }
    verifyEq(map.size, 0)
    
  }
  
  Void testRemove()
  {
    map := ConstHashMap.empty
    count := 1000
    count.times { map = map[it] = it.toStr }
    size := count
    count.times |i| 
    {
      verifyEq(count - i, map.size)
      map = map.remove(i) { verifyEq(i.toStr, it) } 
    }
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
