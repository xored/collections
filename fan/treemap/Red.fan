//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//

**
** Base class for red nodes
** 
internal const class Red : TreeNode
{
  new make(Obj key) : super(key) {}
  
  override TreeNode addLeft(TreeNode child) { red(key, val, child, right) }
  override TreeNode addRight(TreeNode child) 
  { 
    red(key, val, left, child) 
  }
  override TreeNode blacken() { Black(key) }
  override TreeNode redden() { throw Err("Invariant violation") }
}
