//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//


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

  Void testSimple4()
  {
    list := ConstList.fromList([1..100])
    verifyEq(Obj?[1..100], list.toList)
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
    count := 100
    list := ConstList.fromList((0..<count).toList)
    verifyEq(list[0..0].toList, Obj?[0])
    verifyEq(list[0..-1].size, count)
    
    verifyEq(list[count / 2], count / 2)
    
    list = list.removeAt(count / 2)
    verify(list is ChunkedList)
    verifyEq(list.size, count - 1)
    verify(list[0..count/2-1] is SubList)
    verify(list[count/2..count-2] is SubList)

    verifyEq(list[0..1].toList, Obj?[0, 1])
    verifyEq(list[0..count-2].toList, list.toList)
    
    verifyErr(IndexErr#) { list = list[0..count] }
    
    verifyEq(list[(count / 2 - 1)..(count / 2 - 1)].toList, Obj?[(count / 2 - 1)])
    verifyEq(list[(count / 2)..(count / 2)].toList, Obj?[(count / 2 + 1)])
    verifyEq(list[(count / 2 - 1)..(count / 2)].toList, Obj?[(count / 2 - 1), (count / 2 + 1)])
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
  
  **
  ** Creates const list filled with ints from 0 to size - 1
  ** 
  static ConstList create(Int size)
  {
    ConstList.fromList((0..<size).toList)
  }
}
