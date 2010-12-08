//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//

**
** Base class for black nodes
** 
internal const class Black : TreeNode
{
  new make(Obj key) : super(key) {}
  
  override TreeNode addLeft(TreeNode child) { child.balanceLeft(this) }
  override TreeNode addRight(TreeNode child) { child.balanceRight(this) }
  
  override const TreeNode blacken := this
  override TreeNode redden() { Red(key) }
}

