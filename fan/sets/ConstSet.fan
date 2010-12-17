//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov Dec 17, 2010 - Initial Contribution
//

const abstract class ConstSet: ConstColl
{
  const ConstMap impl
  protected new make(ConstMap impl) { this.impl = impl }

  override Obj? eachWhile(|Obj?, Int -> Obj?| func)
  {
    return items.eachWhile(func)
  }
  
  **
  ** Used for coping the set while executing the add/remove operations
  ** Default implementation should be overriden by descendants 
  ** for result instances to maintain the same class 
  ** after executing the add/remove operations
  ** 
  protected abstract This makeCopy(ConstMap impl) 

  **
  ** Returns true if the set contains that item
  ** 
  Bool contains(Obj? item) { impl.containsKey(item) }
  
  **
  ** Returns value at given index. If item is not found,
  ** returns def. 
  ** 
  @Operator Obj? get(Obj? item, Obj? def := null) { contains(item) ? item : def }

  **
  ** Returns the count of items in the set
  ** 
  Int size() { impl.size }
  
  **
  ** Lists the set items in a const sequence
  ** 
  Seq items() { impl.keys }
  
  **
  ** Creates a copy of the set with adding the item specified. 
  ** If the item is in the set already then does nothing. 
  **
  This add(Obj? item) { contains(item) ? this : makeCopy(impl.set(item, item)) }
  
  **
  ** Creates a copy of set with removing the item specified. 
  ** If the item was not in set then does nothing. If func is specified,
  ** it will be called with a given param, so scenario like this is possible:
  **   Obj? val := null 
  **   set = set.remove("item") { val = it } 
  **
  This remove(Obj? item, |Obj?|? func := null)  { contains(item) ? makeCopy(impl.remove(item, func)) : this }
  
  //////////////////////////////////////////////////////////////////////////
  // Integration methods
  //////////////////////////////////////////////////////////////////////////
  **
  ** Converts the const set to a Fantom list. 
  ** 
  override Obj?[] toList() { items.toList }
  
  **
  ** Adds all items of the Fantom list to the const set. 
  ** Default realization might be overriden for speed optimization purposes.
  **
  virtual This addAll(Obj?[] list)
  {
    result := this
    list.each |v| { result = result.add(v)  }
    return result
  } 

  **
  ** Adds all items of the const sequence to the const set. 
  ** Default realization might be overriden for speed optimization purposes.
  **
  virtual This addAllSeq(Seq? seq)
  {
    result := this;
    seq.each |v| { result = result.add(v) }
    return result
  } 

  **
  ** Equality check override
  ** 
  override Bool equals(Obj? that)
  {
    if (that == null) return false
    if (this === that) return true
    if (!(that is ConstSet)) return false

    m := (ConstSet) that
    if (m.size() != this.size() || m.hash() != this.hash()) return false
    
    // empty sets are equal
    if (this.size == 0) return true

//    this.eachWhile
    for (Seq? seq := this.items; seq != null; seq = seq.next)
    {
      if (! m.contains(seq.val)) return false
    }

    return true;
  }

  **
  ** hash override
  ** 
  override Int hash()
  {
    Int result := 0
    items.each |v| { result += v?.hash ?: 0 }
    return result
  }
  
}

