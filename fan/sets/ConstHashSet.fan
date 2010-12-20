//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov Dec 17, 2010 - Initial Contribution
//

const class ConstHashSet : IConstSet
{
  override const ConstHashMap impl
  
  // makeCopy override
  internal new makeByImpl(IConstMap impl) { this.impl = impl }  
  internal override This makeCopy(IConstMap impl) { ConstHashSet.makeByImpl(impl) }  

  // constructors
  new make() { this.impl = ConstHashMap.empty }

//  static ConstHashSet fromList(Obj?[] list) { ConstHashSet().addAll(list) }
//  static ConstHashSet fromSeq(Seq? seq) { ConstHashSet().addAllSeq(seq) }
  
  override IConstSet convertFromList(Obj?[] list) { ConstHashSet().addAll(list) }   
}
