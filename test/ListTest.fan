
class ListTest : Test
{
  Void testSimple()
  {
    list := ConstList.empty.push(1)
    verifyEq(Obj?[1], list.toList)
  }
  
  Void testSimple2()
  {
    list := ConstList.fromList([1,2,3])
    verifyEq(Obj?[1,2,3], list.toList)
  }
  
  Void testSimple3()
  {
    etalon := Obj?[,]
    131072.times { etalon.add(it) }
    verifyEq(etalon, ConstList.fromList(etalon).toList)
  }
  
  Void testSet()
  {
    count := 10000
    val := 1456
    list := ConstList.fromList((0..count).toList)
    count.times
    {
      verifyEq(1456, list.set(it, val).get(it))
    }
  }
  
  Void testPushPop()
  {
    verifyPushPop(ConstList.empty, 10000)
  }
  
  protected Void verifyPushPop(ConstList list, Int count)
  {
    count.times  
    { 
      list = list.push(it)
    }
    count.times
    {
      verifyEq(list.peek, count - it - 1)
      list = list.pop
    }
  }
  Void testGetRange()
  {
    count := 1000000
    list := ConstList.fromList((0..<count).toList)
    verifyEq(list[0..0].toList, Obj?[0])
    verifyEq(list[0..-1].size, count)
    //list := ConstList.fromList()
  }
  
  Void testRemoveAt()
  {
    count := 1000
    list := create(count)
    count.times |i| 
    { 
      verifyEq(list.first, i)
      list = list.removeAt(0)
      verifyType(list, SubList#)
    }
    
  }
  
  private static ConstList create(Int size)
  {
    ConstList.fromList((0..<size).toList)
  }
}
