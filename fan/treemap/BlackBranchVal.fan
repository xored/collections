//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//


**
** Non-leaf black node with value
**
@Js
internal const class BlackBranchVal : BlackBranch
{
  override const Obj? val 
  new make(Obj key, Obj? val, TreeNode? left, TreeNode? right) : super(key, left, right) { this.val = val }
  
  override TreeNode redden() { RedBranchVal(key, val, left, right) }
}
