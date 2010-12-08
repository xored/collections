//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//


**
** Black non-leaf node without val 
**
internal const class BlackBranch : Black
{
  override const TreeNode? left
  override const TreeNode? right
  
  new make(Obj key, TreeNode? left, TreeNode? right) : super(key)
  {
    this.left = left
    this.right = right
  }
  
  override TreeNode redden() { RedBranch(key, left, right) }
}
