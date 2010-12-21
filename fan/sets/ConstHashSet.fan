//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov Dec 17, 2010 - Initial Contribution
//

const class ConstHashSet : ConstSet
{
  override const ConstHashMap impl
  
  // makeCopy override
  internal new makeByImpl(ConstMap impl) { this.impl = impl }  
  internal override ConstSet makeCopy(ConstMap impl) { ConstHashSet.makeByImpl(impl) }  

  // constructors
  new make() { this.impl = ConstHashMap.empty }

  static ConstHashSet fromList(Obj?[] list) { ConstHashSet().addAll(list) }
  static ConstHashSet fromSeq(ConstSeq? seq) { ConstHashSet().addAllSeq(seq) }
  
  override ConstSet convertFromList(Obj?[] list) { ConstHashSet().addAll(list) }   
}
