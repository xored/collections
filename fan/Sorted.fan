//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov 20.12.2010 - Initial Contribution
//


**
** Mixin for sorted collections
**
@Js
const mixin Sorted
{
  ** 
  ** Items compare function, if null, then `Obj.compare` is used
  **   
  //abstract |Obj, Obj -> Int|? comparator()
  abstract Obj? comparator() // instead of above due to Javascript bug
  ** 
  ** Returns a sorted sequence of collection items by the order requested 
  **    
  abstract ConstSeq sorted(Bool asc)
}
