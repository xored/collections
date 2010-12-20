//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution
//


**************************************************************************
** SubList
**************************************************************************
internal const class SubList : ConstList
{

  //////////////////////////////////////////////////////////////////////////
  // Constructor and fields
  //////////////////////////////////////////////////////////////////////////

  private const IConstList parent
  ** Start index in parent list
  private const Int from
  ** Exclusive end index
  private const Int to
  new make(IConstList parent, Int from, Int to)
  {
    this.parent = parent
    this.from = from
    this.to = to
    this.size = to - from
  }
  
  //////////////////////////////////////////////////////////////////////////
  // Overriden methods
  //////////////////////////////////////////////////////////////////////////
  override const Int size
  @Operator override Obj? get(Int i)
  {
    i = normalizeIndex(i) 
    return parent.get(i + from)
  }
 
  @Operator override IConstList getRange(Range r)
  {
    r = normalizeRange(r)
    return SubList(parent, from + r.start, from + r.end + 1)
  }
  
  @Operator override IConstList set(Int i, Obj? obj)
  {
    SubList(parent.set(normalizeIndex(i) + from, obj), from, to)
  }
  
  override IConstList push(Obj? obj)
  {
    SubList(
      to == parent.size ? parent.push(obj) : parent.set(to, obj), 
      from, to + 1)
  }
  
  override IConstList pop()
  {
    isEmpty ? this : SubList(parent, from, to - 1)
  }
}

**************************************************************************
** ChunkedList
**************************************************************************
** 
** Chunked list is a `IConstList#` impl
** which consists of several chunks
** 
internal const class ChunkedList : ConstList
{
  
  //////////////////////////////////////////////////////////////////////////
  // Constructor and fields
  //////////////////////////////////////////////////////////////////////////
  private const IConstList[] chunks
  
  **
  ** Sorted list of indices by chunk
  ** 
  private const Range[] indices
  internal new make(IConstList[] chunks)
  {
    this.chunks = chunks
    Range[] rs := chunks.reduce([,]) |Range[] r, IConstList c -> Range[]|
    {
      r.push( (r.last?.end ?: 0)..<((r.last?.end ?: 0) + c.size))
    }
    this.size = rs.last.end
    this.indices = rs
  }
  
  static IConstList create(IConstList[] chunks)
  {
    chunks = normalizeChunks(chunks)
    return chunks.size > 1 ? ChunkedList(chunks) : chunks.first
  }
  
  //////////////////////////////////////////////////////////////////////////
  // Overriden methods
  //////////////////////////////////////////////////////////////////////////
  override const Int size
  
  @Operator override Obj? get(Int i) 
  { 
    i = normalizeIndex(i)
    ri := index(indices, i)
    reli := i - indices[ri].start
    return chunks[ri][reli]
  }
  
  @Operator override IConstList set(Int i, Obj? o) 
  {
    i = normalizeIndex(i)
    ri := index(indices, i)
    reli := i - indices[ri].start
    return ChunkedList(chunks.map |c, ci| { ci == ri ? c.set(reli, o) : c })
  }
  
  override IConstList pop() 
  { 
    ChunkedList.create(chunks.dup.set(-1, chunks.last.pop))
  }
  
  override IConstList push(Obj? o) 
  { 
    ChunkedList.create(chunks.dup.set(-1, chunks.last.push(o))) 
  }
  //////////////////////////////////////////////////////////////////////////
  // Helper methods
  //////////////////////////////////////////////////////////////////////////
  **
  ** Prevents from defragmentation
  ** 
  static IConstList[] normalizeChunks(IConstList[] chunks)
  {
    flattenChunks(chunks).reduce([,]) |r, i| { collapse(r, i) }
  }
  
  **
  ** If chunk is `ChunkedList#`, returns its chunks
  ** otherwise returns '[chunk]'
  ** 
  private static IConstList[] flattenChunks(IConstList[] chunks)
  {
    chunks.map |c| { 
      c isnot ChunkedList ? 
        [c] :
        flattenChunks( ((ChunkedList)c).chunks ) 
    }.flatten
  }
  
  **
  ** If next chunk is less than a limit, add it to last chunk in the list
  ** 
  private static IConstList[] collapse(IConstList[] list, IConstList next)
  {
    list.isEmpty ? 
      (next.isEmpty ? [,] : [next]) : 
      (next.size < Node.nodeSize ?  
        list.set(-1, list.last.addAll(next.toList)) :
        list.add(next))
  }
  
  internal static Int index(Range[] ranges, Int index)
  {
    result := ranges.binarySearch(index..index) |r1, r2| 
    { 
      r1.start >= r2.end ? 1 : (r2.start >= r1.end ? -1 : 0) 
    }
    return result < 0 ? -(result + 1) : result
  }
}