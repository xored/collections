
class IterableTest : Test
{
  Void testEachn()
  {
    list := ListTest.create(1000)
    iter := 0
    list.eachn(3) |Int? a, Int? b, Int? c, Int i|
    {
      verifyEq(a, i)
      verifyEq(b, i + 1 >= list.size ? null : i + 1)
      verifyEq(c, i + 2 >= list.size ? null : i + 2)
      verifyEq(i, iter * 3)
      iter++
    }
  }
  
  Void testEach2()
  {
    list := ListTest.create(1000)
    list.each2 |a, b| { verifyEq(a, (Int)b - 1) }
  }
  Void testEachWhile()
  {
    list := ListTest.create(100)
    list.eachWhile |Obj? o, Int i -> Obj?|
    {
      verifyEq(o, i)
      return null
    }
    
    verifyEq(list.eachWhile |Obj? o, Int i -> Obj?| { i > 5 ? o : null }, 6)
  }
  
  Void testEachrWhile()
  {
    list := ListTest.create(100)
    list.eachrWhile |Obj? o, Int i -> Obj?|
    {
      verifyEq(o, i)
      return null
    }
    
    verifyEq(list.eachrWhile |Obj? o, Int i -> Obj?| { i < 5 ? o : null }, 4) 
  }
  
  Void testMap()
  {
    verifyFunc(
      1000, 
      "map", 
      [,], 
      |Int i -> Obj?| { i * 2 },
      |o| { o->toList })
  }
  
  Void testReduce()
  {
    verifyFunc(
      1000,
      "reduce",
      Obj?[0],
      |Int r, Int i -> Obj?| { r * i }
      )
  }
  
  Void testAll()
  {
    verifyFunc(
      1000,
      "all",
      [,],
      |Int i -> Bool| { i < 1000 }
      )
    
    verifyFunc(
      1000,
      "all",
      [,],
      |Int i -> Bool| { i > 1000 }
      )
  }
  
  Void testAny()
  {
    verifyFunc(
      1000,
      "any",
      [,],
      |Int i -> Bool| { i < 500 }
      )
    
    verifyFunc(
      1000,
      "any",
      [,],
      |Int i -> Bool| { i > 500 }
      )
  }
  
  Void testFindAll()
  {
    verifyFunc(1000, "findAll", [,], |Int i -> Bool| { i%2 == 0}, |o| { o->toList })
  }
  
  Void testExclude()
  {
    verifyFunc(1000, "exclude", [,], |Int i -> Bool| { i%2 == 0}, |o| { o->toList })
  }
  
  Void testFind()
  {
    cl :=  ConstList.fromList(["foo", 1, `/`])
    verifyEq(`/`, cl.find { it is Uri })
    verifyEq(1, cl.find { it is Int })
  }
  
  Void testFindIndex()
  {
    cl :=  ConstList.fromList(["foo", 1, `/`])
    verifyEq(2, cl.findIndex { it is Uri })
    verifyEq(1, cl.findIndex { it is Int })
  }
  
  Void testFindType()
  {
    cl := ConstList.fromList(["a", 3, "foo", 5sec, null])
    verifyEq(Obj?["a", "foo"], cl.findType(Str#).toList)
  }
  
  Void testMax()
  {
    cl := ListTest.create(1000)
    verifyEq(cl.max, 1000 - 1)
    
    cl = ConstList.fromList(["foo", "bar", "baz"])
    verifyEq("baz", cl.max |Str a, Str b -> Int| { a[-1] <=> b[-1] })
  }
  
  Void testMin()
  {
    cl := ListTest.create(1000)
    verifyEq(cl.min, 0)
    
    cl = ConstList.fromList(["foo", "bar", "baz"])
    verifyEq("foo", cl.min |Str a, Str b -> Int| { a[-1] <=> b[-1] })
  }
  
  Void testSort()
  {
    count := 1000
    l := (0..<count).toList
    cl := ConstList.empty
    count.times
    {
      item := l.random
      cl = cl.add(item)
      l.remove(item)
    }
    cl = cl.sort
    verifyEq(cl.toList, [,].addAll((0..<count).toList))
    
  }
  Void verifyFunc(Int count, Str name, Obj?[] args, Func f, |Obj? -> Obj?| rc := |Obj? o->Obj?| { o })
  {
    cl := ListTest.create(count)
    l := cl.toList
    args = args.add(f)
    cr := cl.trap(name, args)
    lr := l.trap(name, args)
    verifyEq(rc(cr), lr)
  }
  
}
