//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//   Ilya Sherenkov Dec 17, 2010 - Update
//


const mixin IConstStack
{
  abstract IConstStack push(Obj? item)
  
  abstract Obj? peek()
  
  abstract IConstStack pop()
  
  abstract Int size()
  
  virtual Bool isEmpty() { size == 0 }
}
**************************************************************************
** ConstList
**************************************************************************
const mixin IConstList : IConstStack, IConstColl
{
  //////////////////////////////////////////////////////////////////////////
  // Overriden methods
  //////////////////////////////////////////////////////////////////////////
  override Obj? peek() { this[-1] }
  
  abstract IConstList empty()
  
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
  @Operator
  abstract Obj? get(Int index)
  
  **
  ** Sets item
  ** 
  @Operator
  abstract IConstList set(Int index, Obj? item)
  
  **
  ** Overriding to change return type
  ** 
  override abstract IConstList push(Obj? o)
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
  ** Returns a sublist. 
  ** 
  @Operator abstract IConstList getRange(Range r)
  
  **
  ** Takes first 'size.min(count)' items from the list
  ** Default implementation routes to #getRange
  ** 
  virtual IConstList take(Int count) { this[0..<count.min(size)] }
  
  **
  ** Drops first 'count' items from the list
  ** If count is greater size, returns empty list
  ** 
  virtual IConstList drop(Int count) { count >= size ? empty : this[count..-1] }
  
  **
  ** Concatenates this with a given list
  ** 
  abstract IConstList concat(IConstList list) 

  **
  ** Adds all elements from a given list 
  ** Default implementation just adds all items one-by-one,
  ** though inheritors can override in order to provide
  ** more efficient impl
  ** 
  virtual IConstList addAll(Obj?[] objs)
  {
    objs.reduce(this) |IConstList r, Obj? item -> IConstList| { r.add(item) }
  }
  
  **
  ** Removes item at specified index.
  **  
  abstract IConstList removeAt(Int index)

  **
  ** Inserts item at specified index. 
  ** 
  abstract IConstList insert(Int index, Obj? o)
  
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
  virtual IConstList sort(|Obj?, Obj? -> Int|? c := null)
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
  override IConstList map(|Obj?, Int -> Obj?| f)  { (IConstList) IConstColl.super.map(f) }
  override IConstList exclude(|Obj?, Int -> Bool| f) { (IConstList) IConstColl.super.exclude(f) }
  override IConstList findAll(|Obj?, Int -> Bool| f) { (IConstList) IConstColl.super.findAll(f) }
  override IConstList findType(Type t) { (IConstList) IConstColl.super.findType(t) }
  
}