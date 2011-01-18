//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//
 
@Js
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
//    131072.times { etalon.add(it) }
    13072.times { etalon.add(it) }
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
   
    list = create(60);
    list = list.removeAt(40);
    list = list.removeAt(41);
    list = list.removeAt(50);
    list = list.removeAt(54);
    list = list.removeAt(40);
    verifyEq(list.toList, 
       Obj?[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
         21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
         43, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56, 58, 59]
      )
  }
  
  **
  ** Creates const list filled with ints from 0 to size - 1
  ** 
  static ConstList create(Int size)
  {
    ConstList.fromList((0..<size).toList)
  }
  
  Void testList() {
    echo((0..<20).toList.sort)
    
    list := Int[,]
    20.times { list.add(it) }
    echo(list.sort)
  }
  
  Void testEq() {
    verifyEq(ConstList.empty, ConstList.empty)
    verifyEq(ConstList.empty.add(0), ConstList.empty.add(0))
    verifyEq(ConstList.empty, ConstList.empty.add(0).removeAt(0))
    verifyNotEq(ConstList.empty, null)
    verifyNotEq(ConstList.empty.add(0), ConstList.empty.add(1))
    verifyNotEq(ConstList.empty.add(0).add(1), ConstList.empty.add(1).add(0))
    
    list1 := create(10).removeAt(4)
    list2 := ConstList.fromList([0,1,2,3,5,6,7,8,9])
    verifyEq(list1, list2)
    verifyEq(create(1000), create(1000))
  }
}
