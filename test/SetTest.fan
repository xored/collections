//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov Dec 17, 2010 - Initial Contribution
//

class SetTest : Test
{
  Void testSimple()
  {
    doTestSimple(ConstTreeSet())
    doTestSimple(ConstHashSet())
  }
  Void doTestSimple(ConstSet emptySet)
  {
    set := emptySet.add(1)
    verifyEq(Obj?[1], set.toList)
  }
  
  Void testSimple2()
  {
    doTestSimple2(ConstTreeSet())
    doTestSimple2(ConstHashSet())
  }
  Void doTestSimple2(ConstSet emptySet)
  {
    set := emptySet.addAll([1,2,3])
    verifyEq(Obj?[1,2,3], set.toList)
  }
  
  Void testOrdered()
  {
    set := ConstTreeSet.fromList([1,2,3])
    verifyEq(Obj?[3,2,1], set.itemsOrdered(false).toList)
    verifyEq(set.itemsOrdered(true).toList, set.itemsOrdered(false).toList.reverse)
    
    set = ConstTreeSet.fromList([1])
    verifyEq(set.itemsOrdered(true).toList, set.itemsOrdered(false).toList)
  }

  Void testSimple3()
  {
    doTestSimple3(ConstTreeSet())
    doTestSimple3(ConstHashSet())
  }
  Void doTestSimple3(ConstSet emptySet)
  {
    set := emptySet.addAll([1,2,2,2,3,3])
    verifyEq(Obj?[1,2,3], set.toList)
  }

  Void testSimple4()
  {
    doTestSimple4(ConstTreeSet())
    doTestSimple4(ConstHashSet())
  }
  Void doTestSimple4(ConstSet emptySet)
  {
    set := emptySet.addAll([1..100])
    verifyEq(Obj?[1..100], set.toList)
  }

  Void testSimple5()
  {
    doTestSimple5(ConstTreeSet())
    doTestSimple5(ConstHashSet())
  }
  Void doTestSimple5(ConstSet emptySet)
  {
    set := emptySet
    set = set.add(1)
    set = set.add(1)
    set = set.add(2)
    set = set.add(2)
    set = set.add(3)
    set = set.add(3)
    verifyEq(emptySet.addAll([1,2,3]), set)
  }
  
  Void testFromListAndRemove()
  {
    doTestFromListAndRemove(ConstTreeSet())
    doTestFromListAndRemove(ConstHashSet())
  }
  Void doTestFromListAndRemove(ConstSet emptySet)
  {
    set := emptySet.addAll([1,2,2,2,3,3])
    Obj? val := null
    set = set.remove(2) {val = it}
    verifyEq(Obj?[1,3], set.toList)
    verifyEq(val, 2)
  }

  Void testAddFromSeq()
  {
    doTestAddFromSeq(ConstTreeSet())
    doTestAddFromSeq(ConstHashSet())
  }
  Void doTestAddFromSeq(ConstSet emptySet)
  {
    set := emptySet.addAllSeq(ValsSeq(ConstList.fromList([1,1,2,2,3,3]), null))
    verifyEq(Obj?[1,2, 3], set.toList)
  }

  Void testEquality()
  {
    doTestEquality(ConstTreeSet())
    doTestEquality(ConstHashSet())
  }
  Void doTestEquality(ConstSet emptySet)
  {
    verifyEq(emptySet.addAll([,]), emptySet)
    verifyNotEq(emptySet, null)
    
    verifyEq(emptySet.addAll([1]), emptySet.addAll([1]))
    verifyEq(emptySet.addAll([1,2,3]), emptySet.addAll([1,3,2]))
    verifyEq(emptySet.addAll([1,2,2]), emptySet.addAll([2,2,1]))
    verifyEq(emptySet.addAll([1,3,3,4]), emptySet.addAll([4,1,3]))

    verifyEq(emptySet.addAll((0..<1000).toList), emptySet.addAll((0..<1000).toList.reverse))
    
    verifyNotEq(emptySet.addAll([1,2,3]), emptySet.addAll([1,3]))
    verifyNotEq(emptySet.addAll([1,2,3]), emptySet.addAll(['1','2','3']))
  }

  Void testSetWithNullEquality()
  {
//    doTestSetWithNullEquality(ConstTreeSet())
    doTestSetWithNullEquality(ConstHashSet())
  }
  Void doTestSetWithNullEquality(ConstSet emptySet)
  {
    verifyEq(emptySet.addAll([1, null]), emptySet.addAll([null, 1]))
    verifyEq(emptySet.addAll([1, null, null]), emptySet.addAll([null, null, 1]))
    verifyEq(emptySet.addAll([1, null, null]).remove(null), emptySet.addAll([1]))
    set := emptySet.addAll([1, 2, 3])
    set = set.add(null)
    verifyEq(set, emptySet.addAll([null, 1, 2, 3]))
    verifyEq(set.toList, Obj?[null, 1, 2, 3])    
  }
  
  Void testEach()
  {
    doTestEach(ConstTreeSet())
    doTestEach(ConstHashSet())
  }
  Void doTestEach(ConstSet emptySet)
  {
    N := 100000
    set := emptySet.addAll((0..<N).toList)
    sum := 0
    set.each |item| { sum += (Int) item }
    
    verifyEq(sum, (N) * (N - 1) / 2)
  }
}