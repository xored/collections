//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   ivaninozemtsev Dec 8, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//

const class MapEntry
{
  new make(Obj? key, Obj? val) 
  { 
    this.key = key
    this.val = val 
  }
  const Obj? key
  const Obj? val
}

abstract const class MapSeq : ConstSeq
{
  abstract override MapEntry? val()
  abstract override MapSeq? next() 
  static const MapSeq empty := EmptyMapSeq.instance
}

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

internal const class EmptyMapSeq : MapSeq, EmptySeq
{
  private new make() {}
  static const EmptyMapSeq instance := EmptyMapSeq()
  override const MapEntry? val := null
  override const MapSeq? next := null
}

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

internal class Leaf
{
  Obj? val
  new make(Obj? val := null) { this.val = val }
}

const mixin ConstMap: ConstColl
{
  //////////////////////////////////////////////////////////////////////////
  // Abstract methods
  //////////////////////////////////////////////////////////////////////////
  abstract Bool containsKey(Obj? key)
  
  **
  ** Associates given key with value.
  ** This method returns 'This' because return type depends
  ** on concrete impl - TreeMap should return TreeMap and so on
  ** 
  @Operator abstract ConstMap set(Obj? key, Obj? val)
  
  **
  ** Returns value at given index. If item is not found,
  ** returns def. If def is null, returns value at null key
  ** 
  @Operator abstract Obj? get(Obj? key, Obj? def := null)
  
  **
  ** Create copy map with removed the key/value pair identified by the specified key
  ** from the map. If the key was not mapped
  ** then return null. If func is specified,
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
    return entries.eachWhile(func)
  }
  
  virtual ConstSeq keys() { KeySeq(entries) }
  
  virtual ConstSeq vals() { ValSeq(entries) }

  abstract Int size()
  //////////////////////////////////////////////////////////////////////////
  // Integration methods
  //////////////////////////////////////////////////////////////////////////
  **
  ** Converts const map to Fantom map. The value at null key
  ** goes to def field
  ** 
  Obj:Obj? toMap()
  {
    return entries.reduce([:]) |Obj:Obj? r, MapEntry entry -> Obj:Obj?| 
    {
      if (entry.key == null)
        r.def = entry.val 
      else 
        r.add(entry.key, entry.val)
      return r
    }
  }
  
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
  
}