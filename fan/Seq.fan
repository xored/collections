//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   ivaninozemtsev Dec 6, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//

const mixin IConstSeq : IConstColl
{
  abstract Obj? val()
  
  abstract IConstSeq? next()
  
  override IConstColl convertFromList(Obj?[] list) { ValsSeq(ConstList.fromList(list), null) }   

  override Obj? eachWhile(|Obj?, Int -> Obj?| func)
  {
    index := 0
    for (IConstSeq? s := this; s!=null; index++)
    {
      result := func(s.val, index)
      if (result != null) return result
      s = s.next
    }
    return null
  }
  
  // covariance overrides
  override IConstSeq map(|Obj?, Int -> Obj?| f)  { (IConstSeq) IConstColl.super.map(f) }
  override IConstSeq exclude(|Obj?, Int -> Bool| f) { (IConstSeq) IConstColl.super.exclude(f) }
  override IConstSeq findAll(|Obj?, Int -> Bool| f) { (IConstSeq) IConstColl.super.findAll(f) }
  override IConstSeq findType(Type t) { (IConstSeq) IConstColl.super.findType(t) }
  
}

const class HeadSeq : IConstSeq
{
  override const Obj? val
  override const IConstSeq? next
  new make(Obj? val, IConstSeq? next)
  {
    this.val = val
    this.next = next
  }
}

const class ValsSeq : IConstSeq
{
  private const IConstList vals
  private const IConstSeq? nextSeq 
  new make(IConstList vals, IConstSeq? next)
  {
    if(vals.isEmpty) throw ArgErr("Can't create seq on empty list")
    this.vals = vals
    this.nextSeq = next
  }
  
  override Obj? val() { vals.first }
  
  override IConstSeq? next() { vals.size == 1 ? nextSeq : ValsSeq(vals.drop(1), nextSeq) }
}
  
const mixin EmptySeq : IConstSeq
{
  override Obj? eachWhile(|Obj? o, Int i->Obj?| f) { null }
}