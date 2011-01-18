//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   ivaninozemtsev Dec 6, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//

**
** Constrant sequence mixin
** 
@Js
const mixin ConstSeq : ConstColl
{
  **
  ** Current value of the constrant sequence
  ** 
  abstract Obj? val()
  
  **
  ** The rest of the constrant sequence
  ** 
  abstract ConstSeq? next()
  
  override ConstSeq convertFromList(Obj?[] list) { ValsSeq(ConstList.fromList(list), null) }   

  override Obj? eachWhile(|Obj?, Int -> Obj?| func)
  {
    index := 0
    for (ConstSeq? s := this; s!=null; index++)
    {
      result := func(s.val, index)
      if (result != null) return result
      s = s.next
    }
    return null
  }
  
  override Bool equiv(Obj? that)
  {
    if (that == null) return false
    if (this === that) return true
    if (!(that is ConstSeq)) return false
    seq1 := this
    seq2 := (ConstSeq) that
    if (seq1.hash != seq2.hash) return false
    while (seq1.val == seq2.val && seq1.next!=null && seq2.next!=null)
    {
      seq1 = seq1.next
      seq2 = seq2.next
    }
    return (seq1.val == seq2.val && seq1.next==null && seq2.next==null)
  }

  override Bool equals(Obj? that) { this.typeof != that?.typeof ? false : equiv(that) }
  
  override Int hash() 
  {
    reduce(0) |Int r, Obj? o -> Int| 
    {
      r = 31 * r + (o?.hash ?: 0);
    }
  }
  
  
  // covariance overrides
  override ConstSeq map(|Obj?, Int -> Obj?| f)  { ConstColl.super.map(f) }
  override ConstSeq exclude(|Obj?, Int -> Bool| f) { ConstColl.super.exclude(f) }
  override ConstSeq findAll(|Obj?, Int -> Bool| f) { ConstColl.super.findAll(f) }
  override ConstSeq findType(Type t) { ConstColl.super.findType(t) }
  
}

**
** Constant sequence with head Obj? value
** 
@Js
const class HeadSeq : ConstSeq
{
  override const Obj? val
  override const ConstSeq? next
  new make(Obj? val, ConstSeq? next)
  {
    this.val = val
    this.next = next
  }
}

**
** Constant sequence created from a list of values
** 
@Js
const class ValsSeq : ConstSeq
{
  private const ConstList vals
  private const ConstSeq? nextSeq 
  new make(ConstList vals, ConstSeq? next)
  {
    if(vals.isEmpty) throw ArgErr("Can't create seq on empty list")
    this.vals = vals
    this.nextSeq = next
  }
  
  override Obj? val() { vals.first }
  
  override ConstSeq? next() { vals.size == 1 ? nextSeq : ValsSeq(vals.drop(1), nextSeq) }
}
  
**
** Empty constant sequence
** 
@Js
const mixin EmptySeq : ConstSeq
{
  override Obj? eachWhile(|Obj? o, Int i->Obj?| f) { null }
}