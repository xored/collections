//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov Dec 17, 2010 - Initial Contribution
//

const class ConstTreeSet : ConstSet
{
  // makeCopy override
  internal new makeByImpl(ConstMap impl) : super.make(impl) { }
  protected override This makeCopy(ConstMap impl) { ConstTreeSet.makeByImpl(impl) }
  
  // constructors
  new make(|Obj, Obj -> Int|? comparator := null) : super(ConstTreeMap(comparator)) { }
  static ConstTreeSet fromList(Obj?[] list, |Obj, Obj -> Int|? comparator := null) { ConstTreeSet(comparator).addAll(list) }
  static ConstTreeSet fromSeq(Seq? seq, |Obj, Obj -> Int|? comparator := null) { ConstTreeSet(comparator).addAllSeq(seq) }

  override ConstColl convertFromList(Obj?[] list) { fromList(list) }   
  
  ** 
  ** Lists the items of the set in a specified order
  ** 
  Seq itemsOrdered(Bool asc) 
  { 
    return KeySeq(((ConstTreeMap)impl).entriesOrdered(asc)) 
  }  
}
