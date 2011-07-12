//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//

@Js
class MapTest : Test
{
  Void testTrivialPositive()
  {
    verifyTrivialPositive(ConstHashMap.empty)
    verifyTrivialPositive(ConstTreeMap.empty)
  }
  
  Void verifyTrivialPositive(ConstMap map)
  {    
    map = map["foo"] = "bar"
    verifyEq(map["foo"], "bar")
    verifyEq(map.keys.toList, Obj?["foo"])
    verify(map.containsKey("foo"))
    verifyEq(false, map.containsKey("not_foo"))
  }
  
  Void test1()
  {
    verifyTest1(ConstHashMap.empty)
    verifyTest1(ConstTreeMap.empty)
  }
  
  Void test2()
  {
    verifyTest2(ConstHashMap.empty)
    verifyTest2 (ConstTreeMap.empty)
  }
  
  Void verifyTest2(ConstMap map)
  {
    count := 100
    count.times
    {
      map = map[count - it] = it.toStr
      verifyEq(map.size, it+1)
    }
    count.times
    {
      verifyEq(map[count - it], it.toStr)
    }
    verifyEq(map.keys.toList.sort, Obj?[,].addAll((1..count).toList))
  }
  Void verifyTest1(ConstMap map)
  {
    count := 100
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
    verifyCollision(ConstHashMap.empty)
    verifyCollision(ConstTreeMap.empty)
  }
  
  Void verifyCollision(ConstMap map)
  {
    c1 := Collider(2, 2)
    c2 := Collider(4, 0)
    c3 := Collider(300000, -299996)
    map = map[c1] = "foo"
    map = map[c2] = "bar"
    map = map[c3] = "baz"
    verifyEq(map[c1], "foo")
    verifyEq(map[c2], "bar")
    verifyEq(map[c3], "baz")

    seq := map.keys
    keys := map.keys.toList
    vals := map.vals.toList
    verifyEq([c1, c2, c3].intersection(keys).size, [c1, c2, c3].union(keys).size)
    verifyEq(["foo", "bar", "baz"].intersection(vals).size, 
      ["foo", "bar", "baz"].union(vals).size)
    
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
  
  Void testRandomFill()
  {
    verifyRandomFill(ConstHashMap.empty, 1000)
    verifyRandomFill(ConstTreeMap.empty, 1000)
  }
  Void verifyRandomFill(ConstMap map, Int size)
  {
    rand := randomVector(size)
    rand.each |v,i|
    { 
      verifyEq(map.size, i)
      map = map[v] = v
    }
    rand.each |v,i|
    {
      verifyEq(map.size, size - i)
      verifyEq(map[v], v)
      map = map.remove(v)
    }
  }
  
  Int[] randomVector(Int count) 
  { 
    result := [,]
    count.times { result.add(Int.random) }
    return result
  }

  Void testNullKey()
  {
    map := ConstHashMap.empty
    
    map = map[1] = 1
    map = map[2] = 2
    map = map[3] = 3
    map = map[null] = null
    verifyEq(map.keys.toList.size, 4)
    verifyEq(true, map.containsKey(null))
    verifyEq(false, map.containsKey(5))

    map = map[null] = 4
    verifyEq(4, map[null])
  }
  
  Void testNullValue()
  {
    ConstMap map := ConstHashMap.empty
    map = map[1] = null
    verifyEq(true, map.containsKey(1))
    verifyEq(null, map[1])
    
    map = ConstTreeMap.empty
    map = map[1] = null
    verifyEq(true, map.containsKey(1))
    verifyEq(null, map[1])
  }
  
  Void testToMap()
  {
    verifyTestToMap(ConstHashMap.empty)
    verifyTestToMap(ConstTreeMap.empty)
  }
  Void verifyTestToMap(ConstMap map)
  {
    map = map[1] = 1
    map = map[2] = 2
    map = map[3] = 3
    fMap := map.toMap
    verifyEq(fMap, Obj:Obj?[1:1,2:2,3:3])
  }

  Void testEach()
  {
    verifyTestEach(ConstHashMap.empty)
    verifyTestEach(ConstTreeMap.empty)
  }
  
  Void verifyTestEach(ConstMap map)
  {
    N := 1000;
    N.times { map = map[it] = it }
    verifyEq(map.findAll |x| { ((MapEntry)x).key != 1 }.toList.size, N - 1)
    sum := 0
    map.each |x| { sum += (Int) ((MapEntry)x).key }
    verifyEq(sum, (N) * (N - 1) / 2)
  }
  
  Void testEq() 
  {
    verifyEq(ConstHashMap.empty, ConstHashMap.empty)
    verifyNotEq(ConstHashMap.empty, ConstTreeMap.empty)
    verify(ConstHashMap.empty.equiv(ConstTreeMap.empty))
    
    verifyEq(ConstHashMap.empty.set(0,1), ConstHashMap.empty.set(0,1))
    verifyEq(ConstTreeMap.empty.set(0,1), ConstTreeMap.empty.set(0,1))
    verifyNotEq(ConstHashMap.empty.set(0,1), ConstTreeMap.empty.set(0,1))
    verify(ConstHashMap.empty.set(0,1).equiv(ConstTreeMap.empty.set(0,1)))
    
    verifyEq(ConstHashMap.empty, ConstHashMap.empty.set(0, 1).remove(0))
    verifyEq(ConstTreeMap.empty, ConstTreeMap.empty.set(0, 1).remove(0))
    verify(ConstHashMap.empty.set(0, 1).remove(0).equiv(ConstTreeMap.empty.set(0, 1).remove(0)))
    
    verifyNotEq(ConstHashMap.empty, null)
    verifyNotEq(ConstTreeMap.empty, null)
    verifyNotEq(ConstHashMap.empty.set(0,1), ConstHashMap.empty.set(0,0))
    verifyNotEq(ConstTreeMap.empty.set(0,1), ConstTreeMap.empty.set(0,0))

    verifyEq(ConstHashMap.empty.set(0, 1).set(1, 2), ConstHashMap.empty.set(1,2).set(0,1))
    verifyEq(ConstTreeMap.empty.set(0, 1).set(1, 2), ConstTreeMap.empty.set(1,2).set(0,1))
    verifyNotEq(ConstHashMap.empty.set(0, 1).set(1, 2), ConstTreeMap.empty.set(1,2).set(0,1))
    verify(ConstHashMap.empty.set(0, 1).set(1, 2).equiv(ConstTreeMap.empty.set(1,2).set(0,1)))
    
    verifyEq(ConstHashMap.empty.set("x", null), ConstHashMap.empty.set("x", null))
  }
  
}

@Js
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
