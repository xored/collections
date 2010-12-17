//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//

class SeqTest : Test
{
  Void test1()
  {
    seq := HeadSeq(0, HeadSeq(1, HeadSeq(2, HeadSeq(3, null))))
    verifyEq(seq.findAll { it > 1 }.toList, Obj?[2,3])
  }
}
