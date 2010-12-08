//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   ivaninozemtsev Dec 8, 2010 - Initial Contribution
//

const mixin ConstMap
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
  @Operator abstract This set(Obj? key, Obj? val)
  
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
  abstract This remove(Obj? key, |Obj?|? func := null)
  **
  ** Returns all entries in this map  
  ** 
  protected abstract MapSeq entries() 
  
  virtual Seq keys() { KeySeq(entries) }
  
  virtual Seq vals() { ValSeq(entries) }
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
    result := [:]
    if(this.containsKey(null)) result.def = this[null]
    //TODO: implement
    return result
  }
  
  **
  ** Creates const map from Fantom map. The def field goes to 
  ** null key
  ** 
  static ConstMap fromMap(Obj:Obj? map)
  {
    result := ConstHashMap.empty
    map.each |v, k| { result = result[k] = v }
    if(map.def != null) result = result[null] = map.def
    return result
  }
  
}