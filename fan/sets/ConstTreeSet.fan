//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov Dec 17, 2010 - Initial Contribution
//

const class ConstTreeSet : IConstSet, Sorted
{
  override const |Obj, Obj -> Int|? comparator
  override const ConstTreeMap impl  

  // makeCopy override
  internal new makeByImpl(IConstMap impl) 
  { 
    this.impl = impl
    this.comparator = this.impl.comparator 
  }
  internal override This makeCopy(IConstMap impl) { ConstTreeSet.makeByImpl(impl) }
  
  // constructors
  new make(|Obj, Obj -> Int|? comparator := null) 
  { 
    this.impl = ConstTreeMap(comparator) 
    this.comparator = comparator 
  }
  
  static ConstTreeSet fromList(Obj?[] list, |Obj, Obj -> Int|? comparator := null) { ConstTreeSet(comparator).addAll(list) }
  static ConstTreeSet fromSeq(IConstSeq? seq, |Obj, Obj -> Int|? comparator := null) { ConstTreeSet(comparator).addAllSeq(seq) }

  override ConstTreeSet convertFromList(Obj?[] list) { fromList(list) }
  
  // eachrWhile optimization
  override Obj? eachrWhile(|Obj?, Int -> Obj?| func)
  {
    return sorted(false).eachWhile(func)
  }  
  
  ** 
  ** Lists the items of the set in a specified order
  ** 
  override IConstSeq sorted(Bool asc) 
  { 
    return KeySeq(impl.sorted(asc)) 
  }  
}
