const mixin ConstStack
{
  abstract ConstStack push(Obj? item)
  
  abstract Obj? peek()
  
  abstract ConstStack pop()
  
  abstract Int size()
}
**************************************************************************
** ConstList
**************************************************************************
const mixin ConstList : ConstStack
{
  //////////////////////////////////////////////////////////////////////////
  // Overriden methods
  //////////////////////////////////////////////////////////////////////////
  override Obj? peek() { this[-1] }
  
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
  abstract ConstList set(Int index, Obj? item)
  
  **
  ** Overriding to change return type
  ** 
  override abstract ConstList push(Obj? o)
  //////////////////////////////////////////////////////////////////////////
  // Convenience methods
  //////////////////////////////////////////////////////////////////////////
  
  **
  ** Adds item to the end of the list. Same as `#push`
  ** 
  ConstList add(Obj? item) { push(item) }
  
  Obj? first() { isEmpty ? null : this[0] }
  
  Obj? last() { isEmpty ? null : this[-1] }
  
  Bool isEmpty() { size == 0 }
  
  ** Converts const list to Fantom list. 
  ** Default implementation uses `#get`,
  ** however inheritors may override in
  ** order to provide more efficient impl
  ** 
  virtual Obj?[] toList()
  {
    result := [,]
    size.times { result.add(this[it]) }
    return result
  }
  
  **
  ** Returns a sublist. Default implementation just creates new `SubList#` from 'this'
  ** 
  @Operator virtual ConstList getRange(Range r)
  {
    r = normalizeRange(r)
    return SubList(this, r.start, r.end+1)
  }

  
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
  ** Concatenates this with a given list
  ** This method has been added to distinguish from `#addAll` by arg type
  ** Default implementation just creates ChunkedList
  ** 
  virtual ConstList concat(ConstList list) 
  {
    ChunkedList.create([this, list])
  }
  
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
  ** Removes item at specified index. 
  ** Default implementation creates chunked list, inheritors
  ** can override in order to provide better performance
  ** 
  virtual ConstList removeAt(Int index)
  {
    index = normalizeIndex(index)
    return index == size - 1 ? pop : ChunkedList.create([take(index), drop(index + 1)])
  }
  
  virtual ConstList insert(Int index, Obj? o)
  {
    index = normalizeIndex(index)
    return index == size - 1 ? push(o) : ChunkedList.create([take(index).push(o), drop(index)])
  }
  
  //////////////////////////////////////////////////////////////////////////
  // Creation
  //////////////////////////////////////////////////////////////////////////
  static const ConstList empty := CList.emptyCList
  static ConstList fromList(Obj?[] list) 
  { 
    //list.reduce(empty) |r, e| { r->push(e) } 
    CList.createFromList(list)
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

}