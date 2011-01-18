//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov Dec 17, 2010 - Initial Contribution
//

@Js
const mixin ConstSet: ConstColl
{
  abstract ConstMap impl()

  override Obj? eachWhile(|Obj?, Int -> Obj?| func)
  {
    return size==0 ? null : items.eachWhile(func)
  }

  **
  ** Used for coping the set while executing the add/remove operations
  ** Implementation should be overriden by descendants 
  ** 
  internal abstract ConstSet makeCopy(ConstMap impl) 

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
  virtual Int size() { impl.size }
  
  **
  ** Lists the set items in a const sequence
  ** 
  ConstSeq items() { impl.keys }
  
  **
  ** Creates a copy of the set with adding the item specified. 
  ** If the item is in the set already then does nothing. 
  **
  ConstSet add(Obj? item) { contains(item) ? this : makeCopy(impl.set(item, item)) }
  
  **
  ** Creates a copy of set with removing the item specified. 
  ** If the item was not in set then does nothing. If func is specified,
  ** it will be called with a given param, so scenario like this is possible:
  **   Obj? val := null 
  **   set = set.remove("item") { val = it } 
  **
  ConstSet remove(Obj? item, |Obj?|? func := null)  { contains(item) ? makeCopy(impl.remove(item, func)) : this }
  
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
  virtual ConstSet addAll(Obj?[] list)
  {
    list.reduce(this) |ConstSet r, Obj? item -> ConstSet|  { r.add(item) }
  } 

  **
  ** Adds all items of the const sequence to the const set. 
  ** Default realization might be overriden for speed optimization purposes.
  **
  virtual ConstSet addAllSeq(ConstSeq? seq)
  {
    seq.reduce(this) |ConstSet r, Obj? item -> ConstSet|  { r.add(item) }
  } 

  override Bool equiv(Obj? that)
  {
    if (that == null) return false
    if (this === that) return true
    if (!(that is ConstSet)) return false

    set := (ConstSet) that
    if (set.size() != this.size() || set.hash() != this.hash()) return false
    
    // empty sets are equiv   
    if (this.size == 0) return true // size = 0 maps have EmptyMapSeq entries, witch will crash next cycle

    for (ConstSeq? seq := this.items; seq != null; seq = seq.next)
    {
      if (! set.contains(seq.val)) return false
    }

    return true
  }
  
  **
  ** Equality check override
  ** 
  override Bool equals(Obj? that) { this.typeof != that?.typeof ? false : equiv(that) }

  **
  ** hash override
  ** 
  override Int hash()
  {
    items.reduce(0) |Int result, Obj? v -> Int|  {result += v?.hash ?: 0}
  }
  
  // covariance overrides
  override ConstSet map(|Obj?, Int -> Obj?| f)  { ConstColl.super.map(f) }
  override ConstSet exclude(|Obj?, Int -> Bool| f) { ConstColl.super.exclude(f) }
  override ConstSet findAll(|Obj?, Int -> Bool| f) { ConstColl.super.findAll(f) }
  override ConstSet findType(Type t) { ConstSet.super.findType(t) }
}

