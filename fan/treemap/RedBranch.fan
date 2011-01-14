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
@Js
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
      TreeUtils.red(key, val, left.blacken(), TreeUtils.black(parent.key, parent.val(), right, parent.right())) :
      (right is Red ? TreeUtils.red(right.key, right.val(), 
        TreeUtils.black(key, val(), left, right.left()),
        TreeUtils.black(parent.key, parent.val(), right.right(), parent.right())) : 
        super.balanceLeft(parent))
  }
  override TreeNode balanceRight(TreeNode parent) 
  { 
    right is Red ?
      TreeUtils.red(key, val(), TreeUtils.black(parent.key, parent.val(), parent.left(), left), right.blacken()) :
      (left is Red ? TreeUtils.red(left.key, left.val(), 
         TreeUtils.black(parent.key, parent.val(), parent.left(), left.left()),
         TreeUtils.black(key, val(), left.right(), right)) :
         super.balanceRight(parent))
  }
}
