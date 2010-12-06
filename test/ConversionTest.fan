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
    clist := CList.createFromList(list)
    list.size.times |i|
    {
      verifyEq(list[i], clist[i])
    }
  }
  private Obj?[] createList(Int size) { (0..<size).toList }
}
