//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   ivaninozemtsev Dec 6, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//

const mixin Seq : ConstColl
{
  abstract Obj? val()
  
  abstract Seq? next()
  
  override ConstColl convertFromList(Obj?[] list) { ValsSeq(ConstList.fromList(list), null) }   

  override Obj? eachWhile(|Obj?, Int -> Obj?| func)
  {
    index := 0
    for (Seq? s := this; s!=null; index++)
    {
      result := func(s.val, index)
      if (result != null) return result
      s = s.next
    }
    return null
  }
  
}

const class HeadSeq : Seq
{
  override const Obj? val
  override const Seq? next
  new make(Obj? val, Seq? next)
  {
    this.val = val
    this.next = next
  }
}

const class ValsSeq : Seq
{
  private const ConstList vals
  private const Seq? nextSeq 
  new make(ConstList vals, Seq? next)
  {
    if(vals.isEmpty) throw ArgErr("Can't create seq on empty list")
    this.vals = vals
    this.nextSeq = next
  }
  
  override Obj? val() { vals.first }
  
  override Seq? next() { vals.size == 1 ? nextSeq : ValsSeq(vals.drop(1), nextSeq) }
}
  
const mixin EmptySeq : Seq
{
  override Obj? eachWhile(|Obj? o, Int i->Obj?| f) { null }
}