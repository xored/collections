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
internal const class RedBranch : Red
{
  override const TreeNode? left
  override const TreeNode? right
  
  new make(Obj key, TreeNode? left, TreeNode? right) : super(key)
  {
    this.left = left
    this.right = right
  }
  
  override TreeNode blacken() { BlackBranch(key, left, right) }
  
  override TreeNode balanceLeft(TreeNode parent) 
  { 
    left is Red ? 
      red(key, val, left.blacken(), black(parent.key, parent.val(), right, parent.right())) :
      (right is Red ? red(right.key, right.val(), 
        black(key, val(), left, right.left()),
        black(parent.key, parent.val(), right.right(), parent.right())) : 
        super.balanceLeft(parent))
  }
  override TreeNode balanceRight(TreeNode parent) 
  { 
    right is Red ?
      red(key, val(), black(parent.key, parent.val(), parent.left(), left), right.blacken()) :
      (left is Red ? red(left.key, left.val(), 
         black(parent.key, parent.val(), parent.left(), left.left()),
         black(key, val(), left.right(), right)) :
         super.balanceRight(parent))
  }
}
