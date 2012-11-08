//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   ivaninozemtsev Dec 8, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//

**
** Entry of a const map
** 
@Js
const class MapEntry
{
  **
  ** Entry of a const map key:value constructor
  ** 
  new make(Obj? key, Obj? val) 
  { 
    this.key = key
    this.val = val 
  }
  **
  ** Mapped key
  ** 
  const Obj? key
  **
  ** Mapped value
  ** 
  const Obj? val
}

**
** Constant sequence of map entries
** 
@Js
abstract const class MapSeq : ConstSeq
{
  **
  ** Current map entry of the const sequence
  ** 
  abstract override MapEntry? val()
  **
  ** The rest of the const sequence
  ** 
  abstract override MapSeq? next() 
  **
  ** Empty constant sequence of map entries
  ** 
  static const MapSeq empty := EmptyMapSeq.instance
}

@Js
internal const class MapEntrySeq: MapSeq
{
  override const MapEntry? val := null
  override const MapSeq? next := null
  new make(MapEntry? val, MapSeq? next)
  {
    this.val = val
    this.next = next
  }
}

@Js
internal const class EmptyMapSeq : MapSeq, EmptySeq
{
  private new make() {}
  static const EmptyMapSeq instance := EmptyMapSeq()
  override const MapEntry? val := null
  override const MapSeq? next := null
}

@Js
internal const class NullHeadMapEntrySeq : MapSeq
{
  private const MapSeq nextSeq
  private const Obj? nullVal
  override const MapEntry? val := MapEntry(null, nullVal)

  new make(Obj? nullVal, MapSeq nextSeq) 
  { 
    this.nextSeq = nextSeq
    this.nullVal = nullVal
  }
  
  override MapSeq? next() { nextSeq }
}

@Js
internal const class KeySeq : ConstSeq
{
  private const MapSeq seq
  new make(MapSeq seq) { this.seq = seq }
  override Obj? val() { seq.val?.key }
  override KeySeq? next() 
  { 
    result := seq.next
    return result == null ? null : KeySeq(result)
  }
}

@Js
internal const class ValSeq : ConstSeq
{
  private const ConstSeq seq
  new make(ConstSeq seq) { this.seq = seq }
  override Obj? val() 
  { 
    (seq.val as MapEntry)?.val 
  }
  override ValSeq? next() 
  { 
    result := seq.next
    return result == null ? null : ValSeq(result)
  }
}

@Js
internal class Leaf
{
  Obj? val
  new make(Obj? val := null) { this.val = val }
}

@Js
const mixin ConstMap: ConstColl
{
  static const ConstMap emptyHashMap := ConstHashMap.empty
  static ConstMap hashMap(Map map) 
  {
    result := emptyHashMap
    map.each |v,k| { result = result.set(k,v) }
    return result
  }
  
  //////////////////////////////////////////////////////////////////////////
  // Abstract methods
  //////////////////////////////////////////////////////////////////////////
  **
  ** Returns true when the given key 
  ** is contained by the map
  ** 
  abstract Bool containsKey(Obj? key)
  
  **
  ** Associates given key with the value.
  ** This method returns the same type 
  ** on concrete impl - ConstTreeMap returns ConstTreeMap and so on
  ** 
  @Operator abstract ConstMap set(Obj? key, Obj? val)
  
  **
  ** Returns value at a given index. If an item is not found,
  ** returns def. If def is null, returns the value at null key
  ** 
  @Operator abstract Obj? get(Obj? key, Obj? def := null)
  
  **
  ** Create a copy of the map with removed key/value pair identified by the key specified.
  ** If the key specified was not mapped then returns null. If func is specified,
  ** it will be called with a given param,
  ** so scenario like this is possible:
  **   Obj? val := null 
  **   map = map.remove("key") { val = it } 
  **
  ** 
  abstract ConstMap remove(Obj? key, |Obj?|? func := null)

  **
  ** Returns all entries in this map  
  ** 
  abstract MapSeq entries()

  override Obj? eachWhile(|Obj?, Int -> Obj?| func)
  {
    return size == 0 ? null : entries.eachWhile(func)
  }
  
  **
  ** Sequence of map entries keys
  ** 
  virtual ConstSeq keys() { KeySeq(entries) }
  
  **
  ** Sequence of map entries values
  ** 
  virtual ConstSeq vals() { ValSeq(entries) }

  **
  ** The size of the map
  ** 
  abstract Int size()
  
  **
  ** Convenience for 'size == 0'
  ** 
  virtual Bool isEmpty() { size ==0 }
  //////////////////////////////////////////////////////////////////////////
  // Integration methods
  //////////////////////////////////////////////////////////////////////////
  **
  ** Converts const map to Fantom map. The value at null key
  ** goes to def field
  ** 
  Obj:Obj? toMap()
  {
    return size == 0 ? [:] :
      entries.reduce([:]) |Obj:Obj? r, MapEntry entry -> Obj:Obj?| 
      {
        if (entry.key == null)
          r.def = entry.val 
        else 
          r.add(entry.key, entry.val)
        return r
      }
  }
  
  override Str toStr() { toMap().toStr() }
  
  // covariance overrides
  override ConstMap map(|Obj?, Int -> Obj?| f)  { ConstColl.super.map(f) }
  override ConstMap exclude(|Obj?, Int -> Bool| f) { ConstColl.super.exclude(f) }
  override ConstMap findAll(|Obj?, Int -> Bool| f) { ConstColl.super.findAll(f) }
  override ConstMap findType(Type t) { ConstColl.super.findType(t) }
 
  **
  ** Adds all items of the Fantom list of MapEntry to the const map. 
  ** Default realization might be overriden for speed optimization purposes.
  **
  virtual ConstMap addAll(Obj?[] list)
  {
    list.reduce(this) |ConstMap r, MapEntry entry -> ConstMap|  { r = r[entry.key] = entry.val }
  } 

  **
  ** Adds all items of the const sequence of MapEntry to the const map. 
  ** Default realization might be overriden for speed optimization purposes.
  **
  virtual ConstMap addAllSeq(ConstSeq? seq)
  {
    seq.reduce(this) |ConstMap r, MapEntry entry -> ConstMap|  { r = r[entry.key] = entry.val }
  } 
 
  **
  ** Adds const map items from Fantom map. The def field goes to 
  ** null key
  ** 
  virtual ConstMap addAllMap(Obj:Obj? map)
  {
    result := this
    if (map.def != null) result = result[null] = map.def
    return map.reduce(result) |ConstMap r, Obj? v, Obj k -> ConstMap| { result = result[k] = v }
  }
 
  override Bool equiv(Obj? that)
  {
    if (that == null) return false
    if (this === that) return true
    if (!(that is ConstMap)) return false
    map := (ConstMap) that

    if (map.size() != this.size() || map.hash() != this.hash()) return false
  
    if (map.size == 0) return true // size = 0 maps have EmptyMapSeq entries, witch will crash next cycle 
    
    for (MapSeq? s := this.entries; s != null; s = s.next())
    {
      e :=  s.val
      found := map.containsKey(e.key)
      if (!found || e.val != map[e.key]) return false
    }
    return true
  }  

  override Bool equals(Obj? that) { this.typeof != that?.typeof ? false : equiv(that) }

  override Int hash() 
  {
    size==0 ? 0 : entries.reduce(0) |Int r, MapEntry e -> Int| 
    {
      r += (e.key?.hash ?: 0).xor(e.val?.hash ?: 0)
    }
  }

}
  
  
