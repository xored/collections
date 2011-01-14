//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 8, 2010 - Initial Contribution
//
@Js
const mixin ConstStack
{
  abstract Int size()

  abstract Obj? peek()
  
  **
  ** Pops an object from the stack
  ** 
  abstract ConstStack pop() 
  
  **
  ** Pushes an object to the stack
  ** 
  abstract ConstStack push(Obj? val) 

  virtual Bool isEmpty() { size == 0 }
}

**
** 
**
@Js
const class LinkedList : ConstStack
{
  const ConstStack? tail
  override const Int size
  override const Obj? peek
  new make(Obj? peek, LinkedList? tail, Int size)
  {
    this.size = size
    this.peek = peek
    this.tail = tail
  }
  
  override ConstStack pop() { tail ?: LinkedList(null, null, 0) }
  override ConstStack push(Obj? val) { LinkedList(val, this, size + 1) }
  static const LinkedList emptyList := LinkedList(null, null, 0) 
}
