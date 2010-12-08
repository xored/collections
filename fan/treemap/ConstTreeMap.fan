//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 7, 2010 - Initial Contribution
//

internal const class ConstTreeMap : ConstMap, TreeUtils
{
  //////////////////////////////////////////////////////////////////////////
  // Constructor and fields
  //////////////////////////////////////////////////////////////////////////
  ** Key comparer, if null, then `Obj.compare` is used
  const |Obj, Obj -> Int|? comparator
  private const TreeNode? root
  override const Int size
  new make(|Obj, Obj -> Int|? comparator := null) : this.makeTree(0, null, comparator) {}
  
  private new makeTree(Int size, TreeNode? root, |Obj, Obj -> Int|? comparator := null)
  {
    this.root = root
    this.comparator = comparator
    this.size = size
  }
  
  static ConstTreeMap empty(|Obj, Obj -> Int|? c := null) { ConstTreeMap(c) } 
  //////////////////////////////////////////////////////////////////////////
  // Overriden methods
  //////////////////////////////////////////////////////////////////////////
  override This set(Obj? key, Obj? val)
  {
    if(key == null) throw ArgErr("Null keys are not supported by tree map")
    Leaf found := Leaf()
    node := add(root, key, val, found)
    if(node == null) //key was already mapped
    {
      TreeNode foundNode := found.val
      if(foundNode.val === val) return this
      return ConstTreeMap.makeTree(size, replace(root, key, val), comparator)
    }
    return ConstTreeMap.makeTree(size + 1, node.blacken, comparator)
  }
  
  override Obj? get(Obj? key, Obj? def := null) 
  {
    entryAt(key ?: throw nullKeyErr)?.val ?: def
  }
  
  override Bool containsKey(Obj? key) { entryAt(key ?: throw nullKeyErr) != null }
  
  override MapSeq entries() { root == null ? MapSeq.empty : TreeNodeSeq.create(root, true) }
  
  override This remove(Obj? key, |Obj?|? callback := null) 
  { 
    Leaf found := Leaf()
    t := removeNode(root, key ?: throw nullKeyErr, found)
    if(found.val != null) callback?.call( (found.val as TreeNode).val )
    return t == null ?
            (found.val == null ? this : empty): //key not found or it was the last key
            ConstTreeMap.makeTree(size - 1, t, comparator)
  }
  //////////////////////////////////////////////////////////////////////////
  // Impl
  //////////////////////////////////////////////////////////////////////////
  internal Int comp(Obj? a, Obj? b) { comparator?.call(a, b) ?: a <=> b }
  private TreeNode? add(TreeNode? parent, Obj key, Obj? val, Leaf found)
  {
    if(parent == null) return val == null ? Red(key) : RedVal(key, val)
    c := comp(key, parent.key)
    if(c == 0) { found.val = parent; return null }
    nodeToInsert := c < 0 ? 
      add(parent.left, key, val, found) : 
      add(parent.right, key, val, found)
    if(nodeToInsert == null) return null
    return c < 0 ? parent.addLeft(nodeToInsert) : parent.addRight(nodeToInsert) 
  }
  
  private TreeNode? entryAt(Obj key)
  {
    t := root
    while(t != null)
    {
      c := comp(key, t.key)
      if(c == 0) return t
      t = c < 0 ? t.left : t.right
    }
    return t
  }
  
  private TreeNode? removeNode(TreeNode? node, Obj key, Leaf found)
  {
    if(node == null) return null
    c := comp(key, node.key)
    if(c == 0)
    {
      found.val = node
      return append(node.left, node.right)
    }
    
    del := c < 0 ? removeNode(node.left, key, found) : removeNode(node.right, key, found);
    if(del == null && found.val == null) return null //not found below
  
    if(c < 0)
    {
      return node.left is Black ? 
        balanceLeftDel(node.key, node.val, del, node.right) :
        red(node.key, node.val, del, node.right)
    }
  
    return node.right is Black ?  
      balanceRightDel(node.key, node.val, node.left, del) :
      red(node.key, node.val, node.left, del)
  }
  private TreeNode replace(TreeNode? root, Obj key, Obj? val) 
  { 
    throw noImpl 
  }
  
  private const Err nullKeyErr := Err("Null keys are not supported")
}



