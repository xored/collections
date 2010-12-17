//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov Dec 17, 2010 - Initial Contribution
//

const class ConstHashSet : ConstSet
{
  // makeCopy override
  internal new makeByImpl(ConstMap impl) : super.make(impl) { }  
  protected override This makeCopy(ConstMap impl) { ConstHashSet.makeByImpl(impl) }  

  // constructors
  new make() : super(ConstHashMap.empty) { }
  static ConstHashSet fromList(Obj?[] list) { ConstHashSet().addAll(list) }
  static ConstHashSet fromSeq(Seq? seq) { ConstHashSet().addAllSeq(seq) }
  
  override ConstColl convertFromList(Obj?[] list) { fromList(list) }   
}
