//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//


**
** Leaf red node of black-red tree 
**
@Js
internal const class RedVal : Red
{
  override const Obj? val
  new make(Obj key, Obj? val) : super(key) { this.val = val }
  
  override TreeNode blacken() { BlackVal(key, val) }
}
