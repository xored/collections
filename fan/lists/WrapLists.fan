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
  private const ConstList parent
  ** Start index in parent list
  private const Int from
  ** Exclusive end index
  private const Int to
  new make(ConstList parent, Int from, Int to)
  {
    if (parent isnot SubList)
    {
      this.parent = parent
      this.from = from
      this.to = to
      this.size = to - from
    }
    else
    {
      SubList sub := parent
      this.parent = sub.parent
      this.from = sub.from + from
      this.to = sub.from + to
      this.size = to - from
    }
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
 
  @Operator override ConstList getRange(Range r)
  {
    r = normalizeRange(r)
    return SubList(parent, from + r.start, from + r.end + 1)
  }
  
  @Operator override ConstList set(Int i, Obj? obj)
  {
    SubList(parent.set(normalizeIndex(i) + from, obj), from, to)
  }
  
  override ConstList push(Obj? obj)
  {
    SubList(
      to == parent.size ? parent.push(obj) : parent.set(to, obj), 
      from, to + 1)
  }
  
  override ConstList pop()
  {
    isEmpty ? this : SubList(parent, from, to - 1)
  }
}

**************************************************************************
** ChunkedList
**************************************************************************
** 
** Chunked list is a `ConstList#` impl
** which consists of several chunks
** 
internal const class ChunkedList : ConstList
{
  
  //////////////////////////////////////////////////////////////////////////
  // Constructor and fields
  //////////////////////////////////////////////////////////////////////////
  private const ConstList[] chunks
  
  **
  ** Sorted list of indices by chunk
  ** 
  private const Range[] indices
  internal new make(ConstList[] chunks)
  {
    this.chunks = chunks
    Range[] rs := chunks.reduce([,]) |Range[] r, ConstList c -> Range[]|
    {
      r.push( (r.last?.end ?: 0)..<((r.last?.end ?: 0) + c.size))
    }
    
    this.size = rs.last.end
    this.indices = rs
  }
  
  private static ConstList toCList(ConstList[] chunks) { CList.createFromList(ChunkedList(chunks).toList) }
  
  private static Int countMaxChunksSize(Int allSize)
  {  // set max chunks size to sqrt of all chunk elements count
    return allSize < Node.nodeSize ? 0 : allSize.toFloat.sqrt.round.toInt    
  }
  
  static ConstList create(ConstList[] chunks)
  {
    chunks = normalizeChunks(chunks)
    maxChunksSize := countMaxChunksSize(chunks.reduce(0) |Int r, ConstList c -> Int| { r+=c.size })
    return chunks.size == 1 ? chunks.first : (chunks.size < maxChunksSize ? ChunkedList(chunks) : toCList(chunks)) 
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
  
  @Operator override ConstList set(Int i, Obj? o) 
  {
    i = normalizeIndex(i)
    ri := index(indices, i)
    reli := i - indices[ri].start
    return ChunkedList(chunks.map |c, ci| { ci == ri ? c.set(reli, o) : c })
  }
  
  override ConstList pop() 
  { 
    ChunkedList.create(chunks.dup.set(-1, chunks.last.pop))
  }
  
  override ConstList push(Obj? o) 
  { 
    ChunkedList.create(chunks.dup.set(-1, chunks.last.push(o))) 
  }
  //////////////////////////////////////////////////////////////////////////
  // Helper methods
  //////////////////////////////////////////////////////////////////////////
  **
  ** Prevents from defragmentation
  ** 
  static ConstList[] normalizeChunks(ConstList[] chunks)
  {
    flattenChunks(chunks).reduce([,]) |r, i| { collapse(r, i) }
  }
  
  **
  ** If chunk is `ChunkedList#`, returns its chunks
  ** otherwise returns '[chunk]'
  ** 
  private static ConstList[] flattenChunks(ConstList[] chunks)
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
  private static ConstList[] collapse(ConstList[] list, ConstList next)
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

  **
  ** Replaces the chunk in the list.
  ** 
  internal ConstList replaceChunk(Int chunkIndex, ConstList newChunk)
  {
    ChunkedList.create(chunks.dup[chunkIndex] = newChunk)    
  }
  
  **
  ** Removes the chunk from the list.
  ** 
  internal ConstList removeChunk(Int chunkIndex)
  {
    newChunks := chunks.dup
    newChunks.removeAt(chunkIndex)
    return ChunkedList.create(newChunks)    
  }

  override ConstList removeAt(Int i)
  {
    i = normalizeIndex(i)
    ri := index(indices, i)
    chunk := chunks[ri]
    if (chunk.size==1) return removeChunk(ri)
    // convert the chunk containing the index element into ChunkedList 
    reli := i - indices[ri].start
    return replaceChunk(ri, ChunkedList.create([chunk.take(reli), chunk.drop(reli + 1)]))
  }
  
  override ConstList insert(Int i, Obj? o)
  {
    if (i == size - 1) return push(o) 

    // convert the chunk containing the index element into ChunkedList
    i = normalizeIndex(i)
    ri := index(indices, i)
    chunk := chunks[ri]
    reli := i - indices[ri].start
    return replaceChunk(ri, ChunkedList.create([chunk.take(reli).push(o), chunk.drop(reli)]))
  }
  
  @Operator override ConstList getRange(Range r)
  {
    r = normalizeRange(r)
    riStart := index(indices, r.start)
    riEnd := index(indices, r.end)
    if (riStart == riEnd)
    {
      relStart := indices[riStart].start
      return SubList(chunks[riStart], r.start - relStart, r.end - relStart + 1)    
    }
    else
    {
      relStart := indices[riStart].start
      relEnd := indices[riEnd].start
      newChunks := chunks.map |c, i|
        {
          if (i < riStart) return ConstList.empty
          if (i == riStart) return r.start - relStart == 0 ? c : c.drop(r.start - relStart) 
          if (i == riEnd) return r.end - relEnd + 1 == c.size ? c: c.take(r.end - relEnd + 1)
          if (i > riEnd) return ConstList.empty
          return c
        }
      return ChunkedList(newChunks)
    }
  }
}