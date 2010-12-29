//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//

**
** Base class for Red-black tree nodes
**
internal abstract const class TreeNode 
{
  const Obj key
  new make(Obj key) { this.key = key }
  
  abstract TreeNode blacken()
  abstract TreeNode redden()
  
  virtual TreeNode? left() { null }
  virtual TreeNode? right() { null }
  
  abstract TreeNode addLeft(TreeNode node)
  abstract TreeNode addRight(TreeNode node)
  
  virtual TreeNode balanceLeft(TreeNode p) { TreeUtils.black(p.key, p.val, this, p.right) }
  virtual TreeNode balanceRight(TreeNode p) { TreeUtils.black(p.key, p.val, p.left, this) }
  
  virtual Obj? val() { null }
}
