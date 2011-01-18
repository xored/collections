//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//

 
**
** Provides lot of list-like methods like `#findAll`, `#exclude` and so on
** 
@Js
const mixin ConstColl
{

  **
  ** Iterates every item in the collection starting with index 0 up to
  ** size-1 until the function returns non-null.  If function
  ** returns non-null, then eachWhile breaks the iteration and returns the
  ** resulting object.  Returns null if the function returns
  ** null for every item.  
  **
  abstract Obj? eachWhile(|Obj?, Int -> Obj?| func)

  ** 
  ** Handles the convertion from a Fantom list for the map/findAll mixin implementations
  ** 
  abstract ConstColl convertFromList(Obj?[] list)
  
  **
  ** Calls the specified function for every item in the list starting
  ** with index 0 and incrementing up to size-1.  This method is
  ** readonly safe.
  **
  ** Example:
  **   ["a", "b", "c"].each |Str s| { echo(s) }
  **
  Void each(|Obj?, Int| f) { eachWhile |o, i| { f(o, i); return null } }
  **
  ** Reverse `eachWhile`.  Iterates every item in the list starting
  ** with size-1 down to 0.  If the function returns non-null, then eachrWhile
  ** breaks the iteration and returns the resulting object.  Returns
  ** null if the function returns null for every item.  
  ** Default implementation uses `#each` method to populate temporary
  ** `sys::List` internally, so it is strongly
  ** recommended to override this method for better performance
  **
  virtual Obj? eachrWhile(|Obj?, Int -> Obj?| func)
  {
    stack := [,]
    each { stack.add(it) }
    return stack.eachrWhile(func)
  }
  
  **
  ** Reverse each - calls the specified function for every item in
  ** the list starting with index size-1 and decrementing down
  ** to 0.  This method is readonly safe.
  **
  ** Example:
  **   ["a", "b", "c"].eachr |Str s| { echo(s) }
  **
  Void eachr(|Obj?, Int| f) { eachrWhile |o, i| { f(o, i); return null } }
  
  **
  ** Calls given function for every 'n' items in the list
  ** Passes n+1 args to func - n items and 1 index
  ** Example:
  **   ["a","b","c"].eachn(2) |a1, a2, i| { echo("$a1 $a2 $i") }
  ** prints:
  **   a b 0
  **   c null 2
  ** 
  Void eachn(Int count, Func f)
  {
    acc := Obj?[,]
    index := 0
    each |v, i| {
      if(acc.size < count) { acc.add(v); return }
      f.callList(acc.add(index))
      acc = [v]
      index += count
    }
    
    if(!acc.isEmpty)
    {
      f.callList(acc.fill(null, count - acc.size).add(index))
    }
  }
  
  **
  ** Convenience method for `#eachn` where n == 2
  ** 
  Void each2(|Obj?, Obj?, Int| f) { eachn(2, f) }
  
  **
  ** Creates a new list which is the result of calling 'f' for
  ** every item in this list.  
  **
  ** Example:
  **   list := [3, 4, 5]
  **   list.map |Int v->Int| { return v*2 } => [6, 8, 10]
  **
  virtual ConstColl map(|Obj?, Int -> Obj?| f)
  {
    result := [,]
    each |v, i| { result.add(f(v, i)) }
    return convertFromList(result)
  }
  
  **
  ** Reduce is used to iterate through every item in the list
  ** to reduce the list into a single value called the reduction.
  ** The initial value of the reduction is passed in as the init
  ** parameter, then passed back to the closure along with each
  ** item.  This method is readonly safe.
  **
  ** Example:
  **   list := [1, 2, 3]
  **   list.reduce(0) |Obj r, Int v->Obj| { return (Int)r + v } => 6
  **
  Obj? reduce(Obj? init, |Obj? r, Obj? v, Int i->Obj?| c)
  {
    result := init
    each |Obj? v, Int i|
    {
      result = c(result, v, i)
    }
    return result
  }
  
  **
  ** Returns true if c returns true for all of the items in
  ** the list.  If the list is empty, returns true. 
  **
  ** Example:
  **   list := ["ant", "bear"]
  **   list.all |Str v->Bool| { return v.size >= 3 } => true
  **   list.all |Str v->Bool| { return v.size >= 4 } => false
  **
  Bool all(|Obj?, Int -> Bool| f)
  {
    eachWhile |o, i| { f(o, i) ? null : "" } == null
  }
  
  **
  ** Returns true if c returns true for any of the items in
  ** the list.  If the list is empty, returns false. 
  **
  ** Example:
  **   list := ["ant", "bear"]
  **   list.any |Str v->Bool| { return v.size >= 4 } => true
  **   list.any |Str v->Bool| { return v.size >= 5 } => false
  **
  Bool any(|Obj?, Int -> Bool| f)
  {
    eachWhile |o, i| { f(o, i) ? "" : null } != null
  }
  
  **
  ** Returns a new list containing the items for which c returns
  ** false.  If c returns true for every item, then returns an
  ** empty list.  The inverse of this method is `#findAll`.  This
  ** method is readonly safe.
  **
  ** Example:
  **   list := [0, 1, 2, 3, 4]
  **   list.exclude |Int v->Bool| { return v%2==0 } => [1, 3]
  **
  virtual ConstColl exclude(|Obj?, Int -> Bool| f)
  {
    findAll |v,i| { !f(v, i) }
  }
  
  **
  ** Returns a new list containing the items for which c returns
  ** true.  If c returns false for every item, then returns an
  ** empty list.  The inverse of this method is `#exclude`.  This
  ** method is readonly safe.
  **
  ** Example:
  **   list := [0, 1, 2, 3, 4]
  **   list.findAll |Int v->Bool| { return v%2!=0 } => [1, 3]
  **
  virtual ConstColl findAll(|Obj?, Int -> Bool| f)
  {
    result := [,]
    each |v, i| { if(f(v, i)) result = result.add(v) }
    return convertFromList(result)
  }

  **
  ** Returns the first item in the list for which c returns true.
  ** If c returns false for every item, then returns null.  
  **
  ** Example:
  **   list := [0, 1, 2, 3, 4]
  **   list.find |Int v->Bool| { return v.toStr == "3" } => 3
  **   list.find |Int v->Bool| { return v.toStr == "7" } => null
  **
  Obj? find(|Obj?, Int -> Bool| f) { eachWhile |v, i| { f(v, i) ? v : null} }
  
  **
  ** Returns the first item in the list for which c returns true
  ** and return the item's index.  If c returns false for every
  ** item, then returns null. 
  **
  ** Example:
  **   list := [5, 6, 7]
  **   list.findIndex |Int v->Bool| { return v.toStr == "7" } => 2
  **   list.findIndex |Int v->Bool| { return v.toStr == "9" } => null
  **
  Int findIndex(|Obj?, Int -> Bool| f) { eachWhile |v, i| { f(v, i) ? i : null } }
  
  **
  ** Returns a new list containing all the items which are an instance
  ** of the specified type such that item.type.fits(t) is true.  Any null
  ** items are automatically excluded.  If none of the items are instance
  ** of the specified type, then an empty list is returned.  The returned
  ** list will be a list of t.  This method is readonly safe.
  **
  ** Example:
  **   list := ["a", 3, "foo", 5sec, null]
  **   list.findType(Str#) => Str["a", "foo"]
  **
  virtual ConstColl findType(Type t) { findAll { it?.typeof?.fits(t) ?: false } }
  
  **
  ** Returns the minimum value of the list.  If c is provided, then it
  ** implements the comparator returning -1, 0, or 1.  If c is null
  ** then the <=> operator is used (shortcut for compare method).  If
  ** the list is empty, returns null.  This method is readonly safe.
  **
  ** Example:
  **   list := ["albatross", "dog", "horse"]
  **   list.min => "albatross"
  **   list.min |Str a, Str b->Int| { return a.size <=> b.size } => "dog"
  **
  Obj? min(|Obj? a, Obj? b->Int|? c := null)
  {
    reduce(null) |Obj? r, Obj? item->Obj?| {
      if(r == null) return item //everything beats null
      if(item == null) return r //everything beats null indeed
      res := c?.call(r, item) ?: r.compare(item)
      return res <= 0 ? r : item //if items are equal, use the first
    }
  }
  
  **
  ** Returns the maximum value of the list.  If c is provided, then it
  ** implements the comparator returning -1, 0, or 1.  If c is null
  ** then the <=> operator is used (shortcut for compare method).  If
  ** the list is empty, returns null.  This method is readonly safe.
  **
  ** Example:
  **   list := ["albatross", "dog", "horse"]
  **   list.max => "horse"
  **   list.max |Str a, Str b->Int| { return a.size <=> b.size } => "albatross"
  **
  Obj? max(|Obj? a, Obj? b->Int|? c := null)
  {
    reduce(null) |Obj? r, Obj? item->Obj?| {
      if(r == null) return item //everything beats null
      if(item == null) return r //everything beats null indeed
      res := c?.call(r, item) ?: r.compare(item)
      return res >= 0 ? r : item //if items are equal, use the first
    }
  }
  
  
  ** 
  ** Converts collection to Fantom list. 
  ** Default implementation uses `#each`,
  ** however inheritors may override in
  ** order to provide more efficient impl
  ** 
  virtual Obj?[] toList()
  {
    result := [,]
    each |v| { result.add(v) }
    return result
  }
 
  **
  ** Determines if the given that collection has equal elements to this one
  ** 
  abstract Bool equiv(Obj? that)
  
}
