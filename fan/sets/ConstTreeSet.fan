//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov Dec 17, 2010 - Initial Contribution
//

@Js
const class ConstTreeSet : ConstSet, Sorted
{
  //override const |Obj, Obj -> Int|? comparator
  override const Obj? comparator // instead of above due to Javascript bug
  override const ConstTreeMap impl  

  // makeCopy override
  internal new makeByImpl(ConstMap impl) 
  { 
    this.impl = impl
    this.comparator = this.impl.comparator 
  }
  internal override ConstSet makeCopy(ConstMap impl) { ConstTreeSet.makeByImpl(impl) }
  
  // constructors
  new make(|Obj, Obj -> Int|? comparator := null) 
  { 
    this.impl = ConstTreeMap(comparator) 
    this.comparator = comparator 
  }
  
  static ConstTreeSet fromList(Obj?[] list, |Obj, Obj -> Int|? comparator := null) { ConstTreeSet(comparator).addAll(list) }
  static ConstTreeSet fromSeq(ConstSeq? seq, |Obj, Obj -> Int|? comparator := null) { ConstTreeSet(comparator).addAllSeq(seq) }

  override ConstSet convertFromList(Obj?[] list) { fromList(list) }
  
  // eachrWhile optimization
  override Obj? eachrWhile(|Obj?, Int -> Obj?| func)
  {
    return size==0 ? null : sorted(false).eachWhile(func)
  }  
  
  ** 
  ** Lists the items of the set in a specified order
  ** 
  override ConstSeq sorted(Bool asc) 
  { 
    return KeySeq(impl.sorted(asc)) 
  }
  
  override Int size() { ConstSet.super.size } // due to js dynamic invocation bug  
}
