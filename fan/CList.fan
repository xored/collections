//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//


**************************************************************************
** Node
**************************************************************************
const class Node
{
 
  internal static const Int bitWidth := 5
  internal static const Int nodeSize := 1.shiftl(bitWidth)
  internal static const Int indexMask := nodeSize - 1
  internal static const Int inverseMask := indexMask.not
  internal static const Node empty := Node()
  
  new make(Obj?[] objs := [,]) { this.objs = objs }
  const Obj?[] objs
  
  internal static Node fromList(Obj?[] list, Int from := 0)
  {
    Node(list[from..<list.size.min(from + Node.nodeSize)])
    
//    arr := Node.defList.dup
//    for(i := from; i < from + Node.nodeSize && i < list.size; i++)
//      arr[i - from] = list[i] 
//    return Node(arr)
  }
}


**************************************************************************
** CList
**************************************************************************
internal const class CList : ConstList
{
  //////////////////////////////////////////////////////////////////////////
  // Constructor and fields
  //////////////////////////////////////////////////////////////////////////
  private const Node root
  private const Obj?[] tail
  private const Int tailStart
  private const Int depth
  
  internal new make(Int size, Node root, Obj?[] tail)
  {
    this.size = size
    this.root = root
    this.tail = tail
    this.tailStart = size < Node.nodeSize ? 0 : (size - 1).and(Node.inverseMask)
    this.depth = levelFromSize(size)
  }

  private static const Int level1Size := Node.nodeSize * Node.nodeSize + Node.nodeSize
  private static Int levelFromSize(Int size)
  {
    level := 1
    levelSize := level1Size
    while(size > levelSize) 
    {
      levelSize = (levelSize - Node.nodeSize + 1) * Node.nodeSize
      level++
    }
    return level;
  }
  //////////////////////////////////////////////////////////////////////////
  // Overriden methods
  //////////////////////////////////////////////////////////////////////////
  override const Int size
  
  override ConstList push(Obj? obj) 
  {
    //room in tail
    if(inTail(size)) return CList(size + 1, root, tail.dup.add(obj))

    //full tail, push into tree
    Node newRoot := Node.empty
    tailNode := Node(tail)
    //overflow root?
    if(rootIsFull)
      newRoot = Node(Obj?[root, newPath(depth, tailNode)])
    else
      newRoot = pushTail(depth, root, tailNode)
    return CList(size + 1, newRoot, [obj])
  }
  
  override ConstList pop()
  {
    if(size == 0) return this
    if(size == 1) return emptyCList
    if(size - tailStart > 1) return CList(size - 1, root, tail[0..-2])
    
    newTail := arrayFor(size - 2)
    newRoot := popTail(depth, root) ?: Node.empty
    
    if(depth > 1 && newRoot.objs[1] == null)
    {
      newRoot = newRoot.objs.first
    }
    return CList(size - 1, newRoot, newTail)
  }

  @Operator
  override Obj? get(Int i) 
  {
    i = normalizeIndex(i)
    return arrayFor(i)[nodeIndex(i)] 
  }
  
  override ConstList set(Int i, Obj? val)
  {
    i = normalizeIndex(i)
    return i >= tailStart ? 
      CList(size, root, tail.dup.set(nodeIndex(i), val)) :
      CList(size, doSet(depth, root, i, val), tail)
  }
  
  override ConstList removeAt(Int i)
  {
    i = normalizeIndex(i)
     return i >= tailStart ? 
      CList(size - 1, root, tail.dup { it.removeAt(nodeIndex(i)) }) : 
      ConstList.super.removeAt(i)
  }
  
  override ConstList insert(Int i, Obj? o)
  {
    i = normalizeIndex(i)
    return i >= tailStart && inTail(size) ? 
      CList(size + 1, root, tail.insert(nodeIndex(i), o)) : 
      ConstList.super.insert(i, o)
  }
  
  //////////////////////////////////////////////////////////////////////////
  // Tree manipulation
  //////////////////////////////////////////////////////////////////////////
  private Node? popTail(Int depth, Node node)
  {
    subIndex := nodeIndex(levelDown(size - 2, depth))
    if(depth > 1)
    {
      newChild := popTail(depth - 1, node.objs[subIndex])
      if(newChild == null && subIndex == 0) return null
      
      return setVal(node, subIndex, newChild)
    }
    
    if(subIndex == 0) return null
    
    return setVal(node, subIndex, null)
  }
  
  private Node pushTail(Int depth, Node parent, Node tail)
  {
    subIndex := nodeIndex(levelDown(size - 1, depth))
    Node? nodeToInsert
    if(depth == 1)
    {
      nodeToInsert = tail
    }
    else
    {
      child := getVal(parent, subIndex)
      nodeToInsert = child != null ? pushTail(depth - 1, child, tail) : newPath(depth -1, tail)
    }
    return setVal(parent, subIndex, nodeToInsert)
  }
  
  private static Node newPath(Int depth, Node node)
  {
    depth == 0 ? node : Node(Obj?[newPath(depth - 1, node)])
  }
  
  private static Node doSet(Int depth, Node node, Int i, Obj? val)
  {
    if(depth == 0)
      return setVal(node, nodeIndex(i), val)

    subIndex := nodeIndex(levelDown(i, depth))
    return setVal(node, subIndex, doSet(depth - 1, node.objs[subIndex], i, val))
  }
  
  protected Obj?[] arrayFor(Int i)
  {
    if(i >= tailStart) return tail
    node := root
    depth.times { node = node.objs[nodeIndex(levelDown(i, (depth-it)))] }
    return node.objs
  }

  
  //////////////////////////////////////////////////////////////////////////
  // Utility methods
  //////////////////////////////////////////////////////////////////////////
  private static Node setVal(Node node, Int index, Obj? val)
  {
    list := node.objs.dup
    if(index >= list.size) list.size = index + 1
    return Node(list.set(index, val))
  }
  
  private static Obj? getVal(Node node, Int index)
  {
    node.objs.getSafe(index, null)
  }
  
  private Bool inTail(Int index) { index - tailStart < Node.nodeSize }
  private Bool rootIsFull() { size > levelUp(1, depth + 1) }
  
  private static Int levelDown(Int val, Int level := 1) { val.shiftr(level * Node.bitWidth) }
  private static Int levelUp(Int val, Int level := 1) { val.shiftl(level * Node.bitWidth) }
  private static Int nodeIndex(Int i) { i.and(Node.indexMask) }
  
  //////////////////////////////////////////////////////////////////////////
  // Static creation
  //////////////////////////////////////////////////////////////////////////
  static const CList emptyCList := CList(0, Node.empty, [,])
  
  internal static CList createFromList(Obj?[] items)
  {
    //tail only
    if(items.size <= Node.nodeSize) 
    {
      return CList(items.size, Node.empty, items)
    }
    
    //so that we will always have a tail
    size := items.size
    nodeCount := (items.size - 1)/Node.nodeSize
    tail := items[nodeCount * Node.nodeSize ..-1]
    
    items = items[0..<nodeCount * Node.nodeSize]

    while(items.size > 1)
    {
      items = collapse(items)
    }
    
    //now items is a list of nodes which should be just added to the root node
    return CList(size, items.first, tail)
  }
  
  **
  ** Packs given items to nodes
  ** 
  private static Obj?[] collapse(Obj?[] items)
  {
    nodeCount := (items.size + Node.nodeSize - 1)/Node.nodeSize
    result := Obj?[,]
    nodeCount.times
    {
      result.add(Node.fromList(items, it * Node.nodeSize))
    }
    return result
  }
  
  override Obj?[] toList()
  {
    result := List.makeObj(size)
    allObjs(root, result)
    result.addAll(tail)
    return result
  }
  
  private static Void allObjs(Node node, Obj?[] acc)
  {
    if(node.objs.isEmpty) return
    if(node.objs.first isnot Node) //leaf node
    {
      acc.addAll(node.objs)
      return
    }
    node.objs.each { allObjs(it, acc) }
  }
}

