//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//


**
** Tests that conversions from/to list are performed correctly
** 
class ConversionTest : Test
{
  Void testFromList()
  {
    verifyFromList(createList(1))
    verifyFromList(createList(10))
    verifyFromList(createList(100))
    verifyFromList(createList(1000))
    verifyFromList(createList(10000))
    verifyFromList(createList(100000))
    verifyFromList(createList(1000000))
  }
  
  Void testToList()
  {
    verifyToList(ConstList.fromList(createList(1)))
    verifyToList(ConstList.fromList(createList(10)))
    verifyToList(ConstList.fromList(createList(100)))
    verifyToList(ConstList.fromList(createList(1000)))
    verifyToList(ConstList.fromList(createList(10000)))
    verifyToList(ConstList.fromList(createList(100000)))
    verifyToList(ConstList.fromList(createList(1000000)))
  }

  private Void verifyToList(ConstList list)
  {
    l := list.toList
    l.size.times |i| { verifyEq(l[i], list[i]) }
  }
  private Void verifyFromList(Obj?[] list)
  {
    clist := ConstList.fromList(list)
    list.size.times |i|
    {
      verifyEq(list[i], clist[i])
    }
  }
  private Obj?[] createList(Int size) { (0..<size).toList }
}
