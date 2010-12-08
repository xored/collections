//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//

**
** Mixin for red-black tree manipulation
** 
internal mixin TreeUtils
{
  static Err noImpl() { Err("not implemented") }
  
  static Red red(Obj key, Obj? val, TreeNode? left, TreeNode? right)
  {
    (left == null && right == null) ? 
      (val == null ? Red(key) : RedVal(key, val)) :
      (val == null ? RedBranch(key, left, right) : RedBranchVal(key, val, left, right))
  }
  
  static Black black(Obj key, Obj? val, TreeNode? left, TreeNode? right)
  {
    (left == null && right == null) ? 
      (val == null ? Black(key) : BlackVal(key, val)) : 
      (val == null ? BlackBranch(key, left, right) : BlackBranchVal(key, val, left, right))
  }

  static TreeNode? append(TreeNode? left, TreeNode? right) 
  {
    if(left == null) return right
    if(right == null) return left
    
    if(left is Red)
    {
      if(right is Red)
      {
        app := append(left.right(), right.left());
        if(app is Red)
          return red(app.key, app.val,
                   red(left.key, left.val, left.left, app.left),
                   red(right.key, right.val, app.right, right.right))
        return red(left.key, left.val, left.left, red(right.key, right.val, app, right.right))
      }
      else return red(left.key, left.val, left.left, append(left.right, right))
    }
    
    if(right is Red) return red(right.key, right.val, append(left, right.left), right.right)

    app := append(left.right, right.left)
    
    if(app is Red)
      return red(app.key, app.val,
                 black(left.key, left.val, left.left, app.left),
                 black(right.key, right.val, app.right, right.right))
    
    return balanceLeftDel(left.key, left.val, left.left, black(right.key, right.val, app, right.right))
  }
  
  static TreeNode? balanceLeftDel(Obj key, Obj? val, TreeNode? del, TreeNode? right)
  {
    if(del is Red) return red(key, val, del.blacken, right)
    if(right is Black) return rightBalance(key, val, del, right.redden)
    
    if(right is Red && right.left is Black)
      return red(right.left.key, right.left.val,
               black(key, val, del, right.left.left),
               rightBalance(right.key, right.val, right.left.right, right.right.redden));
    throw Err("Invariant violation");
  }
  
  static TreeNode? balanceRightDel(Obj key, Obj? val, TreeNode? left, TreeNode? del)
  {
    if(del is Red) return red(key, val, left, del.blacken)
    if(left is Black) return leftBalance(key, val, left.redden, del)
    
    if(left is Red && left.right is Black)
      return red(left.right().key, left.right().val(),
                 leftBalance(left.key, left.val(), left.left().redden(), left.right().left()),
                 black(key, val, left.right().right(), del))
    throw Err("Invariant violation");
  }
  
  static TreeNode? leftBalance(Obj key, Obj? val, TreeNode? ins, TreeNode? right)
  {
    if(ins is Red && ins.left is Red) 
      return red(ins.key, ins.val, 
                  ins.left.blacken,
                  black(key, val, ins.right, right))

    if(ins is Red && ins.right is Red)
      return red(ins.right.key, ins.right.val,
                 black(ins.key, ins.val, ins.left, ins.right.left),
                 black(key, val, ins.right.right, right))
    else
      return black(key, val, ins, right);
  }
  
  static TreeNode? rightBalance(Obj key, Obj? val, TreeNode? left, TreeNode? ins)
  {
    if(ins is Red && ins.right is Red)
      return red(ins.key, ins.val, black(key, val, left, ins.left), ins.right.blacken)
    
    if(ins is Red && ins.left is Red)
      return red(ins.left.key, ins.left.val,
               black(key, val, left, ins.left.left),
               black(ins.key, ins.val(), ins.left.right, ins.right))

    return black(key, val, left, ins);
  }
}

