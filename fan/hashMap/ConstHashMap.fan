//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update

const class ConstHashMap : ConstMap
{
  //////////////////////////////////////////////////////////////////////////
  // Constructor and fields
  //////////////////////////////////////////////////////////////////////////
  static const ConstHashMap empty := ConstHashMap()
  override const Int size
  private const HashMapNode? root
  private const Bool hasNull
  private const Obj? nullVal
  internal new make(Int size := 0, HashMapNode? root := null, Bool hasNull := false, Obj? nullVal := null)
  {
    this.size = size
    this.root = root
    this.hasNull = hasNull
    this.nullVal = nullVal
  }
  
  override ConstHashMap convertFromList(Obj?[] list) 
  {  
    result := ConstHashMap()
    return result.addAll(list)
  }   

  //////////////////////////////////////////////////////////////////////////
  // Public API
  //////////////////////////////////////////////////////////////////////////
  override Bool containsKey(Obj? key) 
  { 
    key == null ? hasNull : ((root?.find(0, key.hash, key) ?: NotFound.instance) !== NotFound.instance)
  }
  
  @Operator override ConstMap set(Obj? key, Obj? val)
  {
    if(key == null)
    {
      if(hasNull && val == null) return this
      return ConstHashMap(hasNull ? size : size + 1, root, true, val)
    }
    
    HashMapNode newRoot := root ?: BitmapNode.empty
    leaf := Leaf()
    newRoot = newRoot.put(0, key.hash, key, val, leaf)
    if(newRoot === root) return this
    return ConstHashMap(leaf.val == null ? size : size + 1, newRoot, hasNull, nullVal)
  }
  
  @Operator override Obj? get(Obj? key, Obj? def := null)
  {
    if(key == null) return hasNull ? nullVal : def
    result := root?.find(0, key.hash, key) ?: NotFound.instance
    if(result === NotFound.instance) return def ?: this[null]
    return result
  }
  
  override ConstMap remove(Obj? key, |Obj? func|? f := null)
  {
    if(key == null) 
    {
      if(hasNull)
      {
        f?.call(nullVal)
        return ConstHashMap(size - 1, root, false, null)
      } else return this
    }
    if(root == null) return this
    newRoot := root.remove(0, key.hash, key, f)
    if(newRoot === root) return this
    return ConstHashMap(size - 1, newRoot, hasNull, nullVal)
  }

  override MapSeq entries() 
  { 
    result := root?.entries ?: MapSeq.empty
    return hasNull ? NullHeadMapEntrySeq(nullVal, result) : result
  }
  
  
  //////////////////////////////////////////////////////////////////////////
  // Helper methods
  //////////////////////////////////////////////////////////////////////////
}








