//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//


**
** 
**
internal const class BlackVal : Black
{
  override const Obj? val
  public new make(Obj key, Obj? val) : super(key) { this.val = val; }

  override TreeNode redden() { RedVal(key, val) }
}
