//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 6, 2010 - Initial Contribution

internal const class NotFound
{
  private new make() {}
  static const NotFound instance := NotFound()
}

internal const mixin HashMapNode
{
  abstract Obj? find(Int level, Int hash, Obj key)
  
  abstract HashMapNode put(Int level, Int hash, Obj key, Obj? val, Leaf leaf)
  
  abstract HashMapNode? remove(Int level, Int hash, Obj key, |Obj?|? f)
  
  abstract IConstSeq? entries()
  
  //////////////////////////////////////////////////////////////////////////
  // Bit utils
  //////////////////////////////////////////////////////////////////////////
  ** 
  ** The Hamming Weight implementation is taken from Wikipedia,
  **   
  static Int bitCount(Int x)
  {
    x -= x.shiftr(1).and(m1)            //put count of each 2 bits into those 2 bits
    x = x.and(m2) + x.shiftr(2).and(m2) //put count of each 4 bits into those 4 bits 
    x = (x + x.shiftr(4)).and(m4)       //put count of each 8 bits into those 8 bits 
    return (x * h01).shiftr(56);  //returns left 8 bits of x + (x<<8) + (x<<16) + (x<<24) + ... 
  }
  private static const Int m1 := 0x5555555555555555 //binary: 0101...
  private static const Int m2 := 0x3333333333333333 //binary: 00110011..
  private static const Int m4 := 0x0f0f0f0f0f0f0f0f //binary:  4 zeros,  4 ones ...
  private static const Int h01 := 0x0101010101010101 //the sum of 256 to the power of 0,1,2,3...
  
  
  
  ** index of hash on given level in bitmask 
  static Int bitpos(Int hash, Int level) { 1.shiftl(mask(hash, level)) }
  
  ** Returns the value of node index on given level
  static Int mask(Int hash, Int level) { nodeIndex(levelDown(hash, level)) }
  
  static Int levelDown(Int val, Int level := 1) { val.shiftr(level * Node.bitWidth) }
  static Int levelUp(Int val, Int level := 1) { val.shiftl(level * Node.bitWidth) }
  static Int nodeIndex(Int i) { i.and(Node.indexMask) }

  //////////////////////////////////////////////////////////////////////////
  // Array manipulation
  //////////////////////////////////////////////////////////////////////////
  static Obj?[] cloneAndSet(Obj?[] objs, Int i, Obj? val) { objs.dup.set(i, val) }
  static Obj?[] cloneAndSet2(Obj?[] objs, Int i, Obj? val1, Int j, Obj? val2) 
  { 
    objs.dup.set(i, val1).set(j, val2) 
  }
  
  //////////////////////////////////////////////////////////////////////////
  // Node manipulation
  //////////////////////////////////////////////////////////////////////////
  static HashMapNode createNode(Int level, Obj key1, Obj? val1, Int key2hash, Obj? key2, Obj? val2)
  {
    key1hash := key1.hash
    if(key1hash == key2hash)
      return CollisionNode(key1hash, 2, [key1, val1, key2, val2])
    leaf := Leaf()
    return BitmapNode.empty
      .put(level, key1hash, key1, val1, leaf)
      .put(level, key2hash, key2, val2, leaf)
  }
  
  static Obj? removePair(Obj?[] objs, Int idx)
  {
    List.makeObj(objs.size - 2).addAll(objs[0..<2*idx]).addAll(objs[(2*idx+2)..-1])
  }
}

