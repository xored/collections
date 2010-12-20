//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//

internal const class BitmapNode : HashMapNode
{
  //////////////////////////////////////////////////////////////////////////
  // Constructor and fields
  //////////////////////////////////////////////////////////////////////////
  static const BitmapNode empty := BitmapNode()
  
  const Int bitmap
  **
  ** Even indices contain either keys (and in this case item at corresponding odd index contains
  ** val) or nulls (in this case odd index contains child node)
  ** 
  const Obj?[] objs
  new make(Int bitmap := 0, Obj?[] objs := [,]) 
  {
    this.bitmap = bitmap
    this.objs = objs
  }
  
  override Obj? find(Int level, Int hash, Obj key) 
  { 
    bit := bitpos(hash, level)
    if(bitmap.and(bit) == 0) return NotFound.instance
    idx := index(bit)
    keyOrNull := objs[2*idx]
    valOrNode := objs[2*idx+1]
    if(keyOrNull == null) return (valOrNode as HashMapNode).find(level + 1, hash, key)
    if(key == keyOrNull) return valOrNode
    return NotFound.instance
  }
  
  override HashMapNode put(Int level, Int hash, Obj key, Obj? val, Leaf leaf) 
  { 
    bit := bitpos(hash, level)
    idx := index(bit)
    keyIndex := idx * 2
    valIndex := keyIndex + 1
    //the given entry is filled
    if(bitmap.and(bit) != 0)
    {
      keyOrNull := objs[keyIndex]
      valOrNode := objs[valIndex]
      if(keyOrNull == null)
      {
        //valOrNode must contain node in this case
        HashMapNode node := valOrNode
        node = node.put(level + 1, hash, key, val, leaf)
        if(node === valOrNode) 
          return this
        return BitmapNode(bitmap, cloneAndSet(objs, valIndex, node))
      }
      //if it is not null,
      //then we need to compare the given key with key at index by equality
      if(key == keyOrNull)
      {
        //if values are equal, no need to modify anything,
        //otherwise create new node with given value at corrsponding
        //index
        return val == valOrNode ? this : BitmapNode(bitmap, cloneAndSet(objs, valIndex, val))
      }
      
      //This is not yet clear enough for me
      leaf.val = leaf
      
      //keys are not equal, need to spawn one more node
      //so key slot becomes null, and value slot
      //becomes a new bitmap node
      //So we do the following:
      // 1. create new node
      // 2. duplicate ourselves to refer to that node instead of val
      return BitmapNode(bitmap, 
          cloneAndSet2(objs, 
            keyIndex, null, //set key to null
            valIndex, createNode(level + 1, keyOrNull, valOrNode, hash, key, val)
            ))
    } 

    //no entry with such hash code on a given level
    //calculating how many space is occupied in bitmap
    n := bitCount(bitmap)
    
    if(n >= Node.nodeSize/2)
    {
      //more than the half of node is occupied
      //in this case there's no need to have packed structure
      //so we convert current node to array node,
      //which contains just a list of nodes and uses leveled hash
      //as direct index in this list
      nodes := List.makeObj(Node.nodeSize) { size = Node.nodeSize }
      jdx := mask(hash, level)
      nodes[jdx] = empty.put(level + 1, hash, key, val, leaf)
      j := 0
      for(i := 0; i < Node.nodeSize; i++)
      {
        if(bitmap.shiftr(i).and(1) != 0)
        {
          if(objs[j] == null) 
          {
            //current entry is already node, so we just put it
            //to array of nodes as is
            nodes[i] = objs[j+1]
          }
          else 
          {
            //current entry is not packed,
            //creating bitmap node with a single element
            nodes[i] = empty.put(level + 1, objs[j].hash, objs[j], objs[j+1], leaf)
          }
          j += 2  
        }
      }
      return ArrayNode(n + 1, nodes)
    }
    
    //less than half of node is occupied
    //we need to insert new key-val pair into our objs list
    //allocating list with size multiplied by two
    newObjs := List.makeObj((n + 1) * 2)
    //1st part of array
    newObjs.addAll(objs[0..<keyIndex])
    //new pair
    newObjs.add(key).add(val)
    //2nd part of array (if any)
    newObjs.addAll(objs[keyIndex..-1])
    leaf.val = leaf //unclear
    return BitmapNode(bitmap.or(bit), newObjs)
    
  }
  
  override HashMapNode? remove(Int level, Int hash, Obj key, |Obj?|? f) 
  { 
    bit := bitpos(hash, level)
    if(bitmap.and(bit) == 0) return this //nothing to remove
    idx := index(bit)
    keyOrNull := objs[2*idx]
    valOrNode := objs[2*idx+1]
    if(keyOrNull == null)
    {
      HashMapNode? node := valOrNode
      node = node.remove(level + 1, hash, key, f)
      if(node === valOrNode) return this //nothing to remove
      if(node != null) return BitmapNode(bitmap, cloneAndSet(objs, 2 * idx + 1, node))
      if(bitmap == bit) return null
      return BitmapNode(bitmap.xor(bit), removePair(objs, idx))
    }
    if(key == keyOrNull)
    {
      f?.call(valOrNode)
      //TODO: collapse
      return BitmapNode(bitmap.xor(bit), removePair(objs, idx))
    }
    return this
  }
  
  override IConstSeq? entries() { BitmapNodeSeq.create(objs, 0, null) }
  
  ** Index of a given bit in current objs array
  private Int index(Int bit) { bitCount(bitmap.and(bit-1)) }
}



internal const class BitmapNodeSeq : MapSeq
{
  const Int start
  const Obj?[] vals
  const MapSeq? nextSeq
  
  private new make(Obj?[] vals, Int start, IConstSeq? nextSeq)
  {
    this.start = start
    this.vals = vals
    this.nextSeq = nextSeq
  }
  
  override MapEntry? val()
  {
    if(nextSeq != null)
      return nextSeq.val
    return MapEntry(vals[start], vals[start+1])
  }
  
  override MapSeq? next()
  {
    if(nextSeq != null) return create(vals, start, nextSeq.next)
    return create(vals, start + 2, null)
  }
  
  static MapSeq? create(Obj?[] vals, Int i, IConstSeq? s) {
    if(s != null)
      return BitmapNodeSeq(vals, i, s)
    for(j := i; j < vals.size; j+=2) 
    {
      if(vals[j] != null)
        return BitmapNodeSeq(vals, j, null)
      HashMapNode? node := vals[j+1]
      if (node != null) 
      {
        nodeSeq := node.entries()
        if(nodeSeq != null) return BitmapNodeSeq(vals, j + 2, nodeSeq)
      }
    }
    return null
  }
}
