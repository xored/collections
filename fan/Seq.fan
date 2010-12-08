const mixin Seq : Iterable
{
  abstract Obj? val()
  
  abstract Seq? next()
  
  override Obj? eachWhile(|Obj?, Int -> Obj?| func)
  {
    doEachWhile(0, func)
  }
  
  protected Obj? doEachWhile(Int index, |Obj?, Int -> Obj?| func)
  {
    result := func(val, index)
    if(result != null) return result
    return next?.doEachWhile(index++, func)
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