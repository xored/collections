//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//

**************************************************************************
** ConstList
**************************************************************************
@Js
const mixin ConstList : ConstStack, ConstColl
{
  //////////////////////////////////////////////////////////////////////////
  // Static creation
  //////////////////////////////////////////////////////////////////////////
  static const ConstList empty := CList.createEmptyCList
  
  static ConstList fromList(Obj?[] items) { CList.createFromList(items) }

  override ConstList convertFromList(Obj?[] list) { fromList(list) }
  
  **
  ** Returns a sublist. Default implementation just creates new `SubList#` from 'this'
  ** 
  @Operator 
  virtual ConstList getRange(Range r)
  {
    r = normalizeRange(r)
    return SubList(this, r.start, r.end+1)
  }
  
  **
  ** Concatenates this with a given list
  ** This method has been added to distinguish from `#addAll` by arg type
  ** Default implementation just creates ChunkedList
  ** 
  virtual ConstList concat(ConstList list) 
  {
    ChunkedList.create([this, list])
  }
  
  **
  ** Removes item at specified index. 
  ** Default implementation creates chunked list, inheritors
  ** can override in order to provide better performance
  ** 
  virtual ConstList removeAt(Int index)
  {
    index = normalizeIndex(index)
    return index == size - 1 ? pop : ChunkedList.create([take(index), drop(index + 1)])
  }
  
  **
  ** Inserts item at specified index. 
  ** Default implementation creates chunked list, inheritors
  ** can override in order to provide better performance
  ** 
  virtual ConstList insert(Int index, Obj? o)
  {
    index = normalizeIndex(index)
    return index == size - 1 ? push(o) : ChunkedList.create([take(index).push(o), drop(index)])
  }
  
  //////////////////////////////////////////////////////////////////////////
  // Overriden methods
  //////////////////////////////////////////////////////////////////////////
  override Obj? peek() { this[-1] }
  
  **
  ** Default implementation uses `#size` and `#get`
  ** 
  override Obj? eachWhile(|Obj?, Int->Obj?| f)
  {
    for(i := 0; i < size; i++) 
    {
      result := f(this[i], i)
      if(result != null) return result
    }
    return null
  }
  
  **
  ** Default implementation uses `#size` and `#get`
  ** 
  override Obj? eachrWhile(|Obj?, Int->Obj?| f)
  {
    for(i := size - 1; i >= 0; i--)
    {
      result := f(this[i], i)
      if(result != null) return result
    }
    return null
  }
  //////////////////////////////////////////////////////////////////////////
  // Abstract methods
  //////////////////////////////////////////////////////////////////////////
  **
  ** Get is used to return the item at the specified the index.  A
  ** negative index may be used to access an index from the end of the
  ** list.  For example get(-1) is translated into get(size()-1).  The
  ** get method is accessed via the [] shortcut operator.  Throw
  ** IndexErr if index is out of range.  This method is readonly safe.
  **
  @Operator abstract Obj? get(Int index)
  
  **
  ** Sets item
  ** 
  @Operator abstract ConstList set(Int index, Obj? item)
  
  **
  ** Pushes an object to the list. Same as `#add`
  ** 
  override abstract ConstList push(Obj? o)
  
  //////////////////////////////////////////////////////////////////////////
  // Convenience methods
  //////////////////////////////////////////////////////////////////////////
  
  **
  ** Adds item to the end of the list. Same as `#push`
  ** 
  This add(Obj? item) { push(item) }
  
  Obj? first() { isEmpty ? null : this[0] }
  
  Obj? last() { isEmpty ? null : this[-1] }
  
  **
  ** Takes first 'size.min(count)' items from the list
  ** Default implementation routes to #getRange
  ** 
  virtual ConstList take(Int count) { this[0..<count.min(size)] }
  
  **
  ** Drops first 'count' items from the list
  ** If count is greater size, returns empty list
  ** 
  virtual ConstList drop(Int count) { count >= size ? empty : this[count..-1] }
  
  **
  ** Adds all elements from a given list 
  ** Default implementation just adds all items one-by-one,
  ** though inheritors can override in order to provide
  ** more efficient impl
  ** 
  virtual ConstList addAll(Obj?[] objs)
  {
    objs.reduce(this) |ConstList r, Obj? item -> ConstList| { r.add(item) }
  }
  
  **
  ** Return sorted list.  If a method is provided
  ** it implements the comparator returning -1, 0, or 1.  If the
  ** comparator method is null then sorting is based on the
  ** value's <=> operator (shortcut for 'compare' method).  Return this.
  ** Throw ReadonlyErr if readonly.
  **
  ** Example:
  **   s := ["candy", "ate", "he"]
  **
  **   s.sort
  **   // s now evaluates to [ate, candy, he]
  **
  **   s.sort |Str a, Str b->Int| { return a.size <=> b.size }
  **   // s now evaluates to ["he", "ate", "candy"]
  **
  virtual ConstList sort(|Obj?, Obj? -> Int|? c := null)
  {
    convertFromList(toList.sort(c)) 
  }
  
  //////////////////////////////////////////////////////////////////////////
  // Internal utility methods
  //////////////////////////////////////////////////////////////////////////
  protected Int normalizeIndex(Int i)
  {
    i < 0 ? i + size : (i >= size ? throw err(i): i)
  }
  
  **
  ** Converts range to exclusive range with resolved indices
  ** 
  protected Range normalizeRange(Range r)
  {
    from := r.start;
    if (from < 0) from = size + from;
    if (from > size) throw err(from);
    
    to := r.end;
    if (to < 0) to = size + to;
    if (r.exclusive) to--;
    if (to >= size) throw err(to);
    
    return from..to
  }

  protected IndexErr err(Int i) { IndexErr("Index $i is not in 0..<$size range") }

  // covariance overrides
  override ConstList map(|Obj?, Int -> Obj?| f)  { ConstColl.super.map(f) }
  override ConstList exclude(|Obj?, Int -> Bool| f) { ConstColl.super.exclude(f) }
  override ConstList findAll(|Obj?, Int -> Bool| f) { ConstColl.super.findAll(f) }
  override ConstList findType(Type t) { ConstColl.super.findType(t) }
 
  override Bool equiv(Obj? that)
  {
    if (that == null) return false
    if (this === that) return true
    if (!(that is ConstList)) return false
    list := (ConstList) that
    if (this.size != list.size || this.hash != list.hash) return false
    for (i:=0; i<size; i++)
    {
      if (this[i] != list[i]) return false
    }
    return true
  }  

  override Bool equals(Obj? that) { equiv(that) } // ConstList itself is implemented by different types

  override Int hash() 
  {
    reduce(0) |Int r, Obj? o -> Int| 
    {
      r = 31 * r + (o?.hash ?: 0);
    }
  }
  
}