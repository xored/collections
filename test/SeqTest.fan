
class SeqTest : Test
{
  Void test1()
  {
    seq := ValSeq(0, ValSeq(1, ValSeq(2, ValSeq(3, null))))
    verifyEq(seq.findAll { it > 1 }.toList, Obj?[2,3])
  }
}
