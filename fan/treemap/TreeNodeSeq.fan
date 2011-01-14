//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//


**
** Sequence iterating on tree node
**
@Js
internal const class TreeNodeSeq : MapSeq
{
  private new make(ConstStack stack, Bool asc)
  {
    this.stack = stack
    this.asc = asc
  }
  
  override MapEntry? val() 
  { 
    TreeNode? node := stack.peek
    return node == null ? null : MapEntry(node.key, node.val)
  }
  
  override MapSeq? next() 
  { 
    TreeNode? node := stack.peek
    nextStack := push(asc ? node.right : node.left, asc, stack.pop)
    return nextStack.isEmpty ? null : TreeNodeSeq(nextStack, asc)
  }
  
  static TreeNodeSeq create(TreeNode node, Bool asc) { TreeNodeSeq(push(node, asc), asc) }
  
  private static ConstStack push(TreeNode? node, Bool asc, ConstStack stack := LinkedList.emptyList)
  {
    while(node != null)
    {
      stack = stack.push(node)
      node = asc ? node.left : node.right
    }
    return stack
  }
  
  private const Bool asc
  private const ConstStack stack
}

