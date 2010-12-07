
class SeqTest : Test
{
  Void test1()
  {
    seq := HeadSeq(0, HeadSeq(1, HeadSeq(2, HeadSeq(3, null))))
    verifyEq(seq.findAll { it > 1 }.toList, Obj?[2,3])
  }
}
