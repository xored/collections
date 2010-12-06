
class ChunkListTest : Test
{
  Void test1()
  {
    l1 := ConstList.fromList([1,2,3])
    l2 := ConstList.fromList([4,5,6])
    ChunkedList cl := ChunkedList([l1, l2])
    verifyEq(cl.size, 6)
    verifyEq(cl->indices, Obj?[0..<3, 3..<6])
  }
  
  Void testFlatten()
  {
    l1 := ConstList.fromList([1,2,3])
    l2 := ConstList.fromList([4,5,6])
    cl := ChunkedList.create([l1, l2])
    verifyType(cl, CList#)
  }
  
  Void testIndex()
  {
    r := [0..<3, 3..<6, 6..<10]
    3.times { verifyEq(ChunkedList.index(r, it), 0) }
    3.times { verifyEq(ChunkedList.index(r, it + 3), 1) }
    4.times { verifyEq(ChunkedList.index(r, it + 6), 2) }
  }
  
  
}
