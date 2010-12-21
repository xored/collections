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
const mixin Sorted
{
  ** Comparer, if null, then `Obj.compare` is used  
  abstract |Obj, Obj -> Int|? comparator()
  abstract ConstSeq sorted(Bool asc)
}
