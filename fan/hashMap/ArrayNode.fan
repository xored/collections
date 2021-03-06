//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//

@Js
internal const class ArrayNode : HashMapNode
{
  const Int size
  const Obj?[] nodes
  new make(Int size, Obj?[] nodes)
  {
    this.size = size
    this.nodes = nodes
  }
  
  override Obj? find(Int level, Int hash, Obj key) 
  { 
    node := (HashMapNode?) nodes[mask(hash, level)]
    if(node == null) return NotFound.instance
    return node.find(level + 1, hash, key)
  }
  override HashMapNode put(Int level, Int hash, Obj key, Obj? val, Leaf leaf) 
  { 
    idx := mask(hash, level)
    node := (HashMapNode?) nodes[idx]
    if(node == null)
      return ArrayNode(size + 1, 
        cloneAndSet(
          nodes, idx,
          BitmapNode.empty.put(level + 1, hash, key, val, leaf)
        ))
    newNode := node.put(level + 1, hash, key, val, leaf)
    if(newNode === node)
      return this
    return ArrayNode(size, cloneAndSet(nodes, idx, newNode))
  }
  
  override HashMapNode? remove(Int level, Int hash, Obj key, |Obj?|? f) 
  { 
    idx := mask(hash, level)
    node := (HashMapNode?) nodes[idx]
    if(node == null) return this
    newNode := node.remove(level + 1, hash, key, f)
    if(newNode === node) return this
    if(newNode == null)
    {
      if(size < Node.nodeSize/4) return pack(idx)
      //remove node
      return ArrayNode(size - 1, cloneAndSet(nodes, idx, null))
    } else return ArrayNode(size, cloneAndSet(nodes, idx, newNode))
  }
  
  private HashMapNode? pack(Int idx) 
  {
    newSize := 2 * (size - 1)
    //newArray := List.makeObj(newSize) { it.size = newSize } will not work in js
    newArray := Obj?[,]
    newArray.capacity = newSize
    newArray.size = newSize 
    j := 1
    bitmap := 0
    for(i := 0; i < idx; i++)
      if(nodes[i] != null) 
      {
        newArray[j] = nodes[i]
        bitmap = bitmap.or(1.shiftl(i)) 
      }
    
    for(i := idx + 1; i < nodes.size; i++)
      if(nodes[i] != null) 
      {
        newArray[j] = nodes[i]
        bitmap = bitmap.or(1.shiftl(i))
      }
    return BitmapNode(bitmap, newArray)
  }
  
  override ConstSeq? entries() { ArrayNodeSeq.create(nodes, 0, null) }
}

@Js
internal const class ArrayNodeSeq : MapSeq
{
  const Obj?[] nodes
  const Int i
  const MapSeq seq
  private new make(Obj?[] nodes, Int i, MapSeq seq)
  {
    this.nodes = nodes
    this.i = i
    this.seq = seq
  }
  
  static MapSeq? create(Obj?[] nodes, Int i, ConstSeq? seq)
  {
    if(seq != null) return ArrayNodeSeq(nodes, i, seq)
    for(j := i; j < nodes.size; j++)
    {
      if(nodes[j] != null) 
      {
        ns := ((HashMapNode?) nodes[j]).entries
        if(ns != null) return ArrayNodeSeq(nodes, j+1, ns)
      }
    }
    return null
  }
  
  override MapEntry? val() { seq.val }
  override MapSeq? next() { create(nodes, i, seq.next) }
}
