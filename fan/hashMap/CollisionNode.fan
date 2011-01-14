//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//

using constArray

@Js
internal const class CollisionNode : HashMapNode
{
  const Int keyHash
  const Int size
  const ConstArray objs
  new make(Int keyHash, Int size, ConstArray objs)
  {
    this.keyHash = keyHash
    this.size = size
    this.objs = objs
  }
  override Obj? find(Int level, Int hash, Obj key) 
  {
    idx := findIndex(key);
    if(idx < 0)
      return NotFound.instance;
    if(key == objs[idx])
      return objs[idx+1];
    return NotFound.instance;
  }
  
  override HashMapNode put(Int level, Int hash, Obj key, Obj? val, Leaf leaf) 
  {
    if(hash != this.keyHash)
      return BitmapNode(bitpos(hash, level), ConstArray.fromList([null, this]))
    idx := findIndex(key);
    if(idx != -1) {
      if(objs[idx + 1] == val) return this //vals equal
      return CollisionNode(hash, size, cloneAndSet(objs, idx + 1, val));
    }
    
    leaf.val = leaf
    return CollisionNode(hash, size + 1, objs.add(key).add(val));
  }
  
  override HashMapNode? remove(Int level, Int hash, Obj key, |Obj?|? f) 
  { 
    idx := findIndex(key)
    if(idx == -1) return this
    f?.call(objs[idx+1])

    if(size == 1)
      return null
    return CollisionNode(hash, size - 1, removePair(objs, idx/2))
  }
  
  protected Int findIndex(Obj key)
  {
    for(i := 0; i < objs.size; i+= 2) if(key == objs[i]) return i
    return -1
  }
  override ConstSeq? entries() { BitmapNodeSeq.create(objs, 0, null) }
}
