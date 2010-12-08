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
const class LinkedList : ConstStack
{
  override const Int size
  override const Obj? peek
  private const LinkedList? tail
  new make(Obj? peek, LinkedList? tail, Int size)
  {
    this.size = size
    this.peek = peek
    this.tail = tail
  }
  
  override ConstStack pop() { tail ?: emptyList }
  
  override ConstStack push(Obj? val) { LinkedList(val, this, size + 1) }
  
  static const LinkedList emptyList := LinkedList(null, null, 0) 
}
