//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev Dec 7, 2010 - Initial Contribution
//

const mixin ConstMap
{
  //////////////////////////////////////////////////////////////////////////
  // Abstract methods
  //////////////////////////////////////////////////////////////////////////
  abstract Bool containsKey(Obj? key)
  
  **
  ** Associates given key with value.
  ** This method returns 'This' because return type depends
  ** on concrete impl - TreeMap should return TreeMap and so on
  ** 
  @Operator abstract This set(Obj? key, Obj? val)
  
  **
  ** Returns value at given index. If item is not found,
  ** returns def. If def is null, returns value at null key
  ** 
  @Operator abstract Obj? get(Obj? key, Obj? def := null)
  
  **
  ** Create copy map with removed the key/value pair identified by the specified key
  ** from the map. If the key was not mapped
  ** then return null. If func is specified,
  ** it will be called with a given param,
  ** so scenario like this is possible:
  **   Obj? val := null 
  **   map = map.remove("key") { val = it } 
  **
  ** 
  abstract This remove(Obj? key, |Obj?|? func := null)
  **
  ** Returns all keys in this map  
  ** 
  abstract Iterable keys() 
  
  abstract Int size()
  //////////////////////////////////////////////////////////////////////////
  // Integration methods
  //////////////////////////////////////////////////////////////////////////
  **
  ** Converts const map to Fantom map. The value at null key
  ** goes to def field
  ** 
  Obj:Obj? toMap()
  {
    result := [:]
    if(this.containsKey(null)) result.def = this[null]
    //TODO: implement
    return result
  }
  
  **
  ** Creates const map from Fantom map. The def field goes to 
  ** null key
  ** 
  static ConstMap fromMap(Obj:Obj? map)
  {
    result := ConstHashMap.empty
    map.each |v, k| { result = result[k] = v }
    if(map.def != null) result = result[null] = map.def
    return result
  }
  
}
const class ConstHashMap : ConstMap
{
  //////////////////////////////////////////////////////////////////////////
  // Constructor and fields
  //////////////////////////////////////////////////////////////////////////
  static const ConstHashMap empty := ConstHashMap()
  override const Int size
  private const MapNode? root
  private const Bool hasNull
  private const Obj? nullVal
  internal new make(Int size := 0, MapNode? root := null, Bool hasNull := false, Obj? nullVal := null)
  {
    this.size = size
    this.root = root
    this.hasNull = hasNull
    this.nullVal = nullVal
  }
  
  //////////////////////////////////////////////////////////////////////////
  // Public API
  //////////////////////////////////////////////////////////////////////////
  override Bool containsKey(Obj? key) 
  { 
    key == null ? hasNull : ((root?.find(0, key.hash, key) ?: NotFound.instance) !== NotFound.instance)
  }
  
  @Operator override This set(Obj? key, Obj? val)
  {
    if(key == null)
    {
      if(hasNull && val == null) return this
      return ConstHashMap(hasNull ? size : size + 1, root, true, val)
    }
    
    MapNode newRoot := root ?: BitmapNode.empty
    leaf := Leaf()
    newRoot = newRoot.put(0, key.hash, key, val, leaf)
    if(newRoot === root) return this
    return ConstHashMap(leaf.val == null ? size : size + 1, newRoot, hasNull, nullVal)
  }
  
  @Operator override Obj? get(Obj? key, Obj? def := null)
  {
    if(key == null) return hasNull ? nullVal : def
    result := root?.find(0, key.hash, key) ?: NotFound.instance
    if(result === NotFound.instance) return def ?: this[null]
    return result
  }
  
  override This remove(Obj? key, |Obj? func|? f := null)
  {
    if(key == null) 
    {
      if(hasNull)
      {
        f?.call(nullVal)
        return ConstHashMap(size - 1, root, false, null)
      } else return this
    }
    if(root == null) return this
    newRoot := root.remove(0, key.hash, key, f)
    if(newRoot === root) return this
    return ConstHashMap(size - 1, newRoot, hasNull, nullVal)
  }
  //TODO: implement
  override Iterable keys() 
  { 
    hasNull ? ValSeq(nullVal, root?.keys) : (root?.keys ?: EmptySeq.instance) 
  }
  
  
  //////////////////////////////////////////////////////////////////////////
  // Helper methods
  //////////////////////////////////////////////////////////////////////////
}

internal const class NotFound
{
  private new make() {}
  static const NotFound instance := NotFound()
}
internal class Leaf
{
  Obj? val
  new make(Obj? val := null) { this.val = val }
}

internal const mixin MapNode
{
  abstract Obj? find(Int level, Int hash, Obj key)
  
  abstract MapNode put(Int level, Int hash, Obj key, Obj? val, Leaf leaf)
  
  abstract MapNode? remove(Int level, Int hash, Obj key, |Obj?|? f)
  
  abstract Seq? keys()
  
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
  static MapNode createNode(Int level, Obj key1, Obj? val1, Int key2hash, Obj? key2, Obj? val2)
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

internal const class CollisionNode : MapNode
{
  const Int keyHash
  const Int size
  const Obj?[] objs
  new make(Int keyHash, Int size, Obj?[] objs)
  {
    this.keyHash = keyHash
    this.size = size
    this.objs = objs
  }
  override Obj? find(Int level, Int hash, Obj key) 
  {
    idx := findIndex(key);
    if(idx < 0)
      return NotFound.instance;
    if(key == objs[idx])
      return objs[idx+1];
    return NotFound.instance;
  }
  
  override MapNode put(Int level, Int hash, Obj key, Obj? val, Leaf leaf) 
  {
    if(hash != this.keyHash)
      return BitmapNode(bitpos(hash, level), [null, this])
    idx := findIndex(key);
    if(idx != -1) {
      if(objs[idx + 1] == val) return this //vals equal
      return CollisionNode(hash, size, cloneAndSet(objs, idx + 1, val));
    }
    
    leaf.val = leaf
    return CollisionNode(hash, size + 1, objs.dup.add(key).add(val));
  }
  
  override MapNode? remove(Int level, Int hash, Obj key, |Obj?|? f) 
  { 
    idx := findIndex(key)
    if(idx == -1) return this
    f?.call(objs[idx+1])

    if(size == 1)
      return null
    return CollisionNode(hash, size - 1, removePair(objs, idx/2))
  }
  
  protected Int findIndex(Obj key)
  {
    for(i := 0; i < objs.size; i+= 2) if(key == objs[i]) return i
    return -1
  }
  override Seq? keys() { null }
}

internal const class ArrayNode : MapNode
{
  const Int size
  const MapNode?[] nodes
  new make(Int size, MapNode?[] nodes)
  {
    this.size = size
    this.nodes = nodes
  }
  
  override Obj? find(Int level, Int hash, Obj key) 
  { 
    node := nodes[mask(hash, level)]
    if(node == null) return NotFound.instance
    return node.find(level + 1, hash, key)
  }
  override MapNode put(Int level, Int hash, Obj key, Obj? val, Leaf leaf) 
  { 
    idx := mask(hash, level)
    node := nodes[idx]
    if(node == null)
      return ArrayNode(size + 1, 
        cloneAndSet(
          nodes, idx,
          BitmapNode.empty.put(level + 1, hash, key, val, leaf)
        ))
    newNode := node.put(level + 1, hash, key, val, leaf)
    if(newNode === node)
      return this
    return ArrayNode(size, cloneAndSet(nodes, idx, newNode))
  }
  
  override MapNode? remove(Int level, Int hash, Obj key, |Obj?|? f) 
  { 
    idx := mask(hash, level)
    node := nodes[idx]
    if(node == null) return this
    newNode := node.remove(level + 1, hash, key, f)
    if(newNode === node) return this
    if(newNode == null)
    {
      if(size < Node.nodeSize/4) return pack(idx)
      //remove node
      return ArrayNode(size - 1, cloneAndSet(nodes, idx, null))
    } else return ArrayNode(size, cloneAndSet(nodes, idx, newNode))
  }
  
  private MapNode? pack(Int idx) 
  {
    newSize := 2 * (size - 1)
    newArray := List.makeObj(newSize) { it.size = newSize }
    j := 1
    bitmap := 0
    for(i := 0; i < idx; i++)
      if(nodes[i] != null) 
      {
        newArray[j] = nodes[i]
        bitmap = bitmap.or(1.shiftl(i)) 
      }
    
    for(i := idx + 1; i < nodes.size; i++)
      if(nodes[i] != null) 
      {
        newArray[j] = nodes[i]
        bitmap = bitmap.or(1.shiftl(i))
      }
    return BitmapNode(bitmap, newArray)
  }
  
  override Seq? keys() { ArrayNodeSeq.create(nodes, 0, null) }
}

internal const class BitmapNode : MapNode
{
  //////////////////////////////////////////////////////////////////////////
  // Constructor and fields
  //////////////////////////////////////////////////////////////////////////
  static const BitmapNode empty := BitmapNode()
  
  const Int bitmap
  **
  ** Even indices contains either keys (and in this case item at corresponding odd index contains
  ** val) or nulls (in this case odd index contains child node)
  ** 
  const Obj?[] objs
  new make(Int bitmap := 0, Obj?[] objs := [,]) 
  {
    this.bitmap = bitmap
    this.objs = objs
  }
  
  override Obj? find(Int level, Int hash, Obj key) 
  { 
    bit := bitpos(hash, level)
    if(bitmap.and(bit) == 0) return NotFound.instance
    idx := index(bit)
    keyOrNull := objs[2*idx]
    valOrNode := objs[2*idx+1]
    if(keyOrNull == null) return (valOrNode as MapNode).find(level + 1, hash, key)
    if(key == keyOrNull) return valOrNode
    return NotFound.instance
  }
  
  override MapNode put(Int level, Int hash, Obj key, Obj? val, Leaf leaf) 
  { 
    bit := bitpos(hash, level)
    idx := index(bit)
    keyIndex := idx * 2
    valIndex := keyIndex + 1
    //the given entry is filled
    if(bitmap.and(bit) != 0)
    {
      keyOrNull := objs[keyIndex]
      valOrNode := objs[valIndex]
      if(keyOrNull == null)
      {
        //valOrNode must contain node in this case
        MapNode node := valOrNode
        node = node.put(level + 1, hash, key, val, leaf)
        if(node === valOrNode) 
          return this
        return BitmapNode(bitmap, cloneAndSet(objs, valIndex, node))
      }
      //if it is not null,
      //then we need to compare the given key with key at index by equality
      if(key == keyOrNull)
      {
        //if values are equal, no need to modify anything,
        //otherwise create new node with given value at corrsponding
        //index
        return val == valOrNode ? this : BitmapNode(bitmap, cloneAndSet(objs, valIndex, val))
      }
      
      //This is not yet clear enough for me
      leaf.val = leaf
      
      //keys are not equal, need to spawn one more node
      //so key slot becomes null, and value slot
      //becomes a new bitmap node
      //So we do the following:
      // 1. create new node
      // 2. duplicate ourselves to refer to that node instead of val
      return BitmapNode(bitmap, 
          cloneAndSet2(objs, 
            keyIndex, null, //set key to null
            valIndex, createNode(level + 1, keyOrNull, valOrNode, hash, key, val)
            ))
    } 

    //no entry with such hash code on a given level
    //calculating how many space is occupied in bitmap
    n := bitCount(bitmap)
    
    if(n >= Node.nodeSize/2)
    {
      //more than the half of node is occupied
      //in this case there's no need to have packed structure
      //so we convert current node to array node,
      //which contains just a list of nodes and uses leveled hash
      //as direct index in this list
      nodes := List.makeObj(Node.nodeSize) { size = Node.nodeSize }
      jdx := mask(hash, level)
      nodes[jdx] = empty.put(level + 1, hash, key, val, leaf)
      j := 0
      for(i := 0; i < Node.nodeSize; i++)
      {
        if(bitmap.shiftr(i).and(1) != 0)
        {
          if(objs[j] == null) 
          {
            //current entry is already node, so we just put it
            //to array of nodes as is
            nodes[i] = objs[j+1]
          }
          else 
          {
            //current entry is not packed,
            //creating bitmap node with a single element
            nodes[i] = empty.put(level + 1, objs[j].hash, objs[j], objs[j+1], leaf)
          }
          j += 2  
        }
      }
      return ArrayNode(n + 1, nodes)
    }
    
    //less than half of node is occupied
    //we need to insert new key-val pair into our objs list
    //allocating list with size multiplied by two
    newObjs := List.makeObj((n + 1) * 2)
    //1st part of array
    newObjs.addAll(objs[0..<keyIndex])
    //new pair
    newObjs.add(key).add(val)
    //2nd part of array (if any)
    newObjs.addAll(objs[keyIndex..-1])
    leaf.val = leaf //unclear
    return BitmapNode(bitmap.or(bit), newObjs)
    
  }
  
  override MapNode? remove(Int level, Int hash, Obj key, |Obj?|? f) 
  { 
    bit := bitpos(hash, level)
    if(bitmap.and(bit) == 0) return this //nothing to remove
    idx := index(bit)
    keyOrNull := objs[2*idx]
    valOrNode := objs[2*idx+1]
    if(keyOrNull == null)
    {
      MapNode? node := valOrNode
      node = node.remove(level + 1, hash, key, f)
      if(node === valOrNode) return this //nothing to remove
      if(node != null) return BitmapNode(bitmap, cloneAndSet(objs, 2 * idx + 1, node))
      if(bitmap == bit) return null
      return BitmapNode(bitmap.xor(bit), removePair(objs, idx))
    }
    if(key == keyOrNull)
    {
      f?.call(valOrNode)
      //TODO: collapse
      return BitmapNode(bitmap.xor(bit), removePair(objs, idx))
    }
    return this
  }
  
  override Seq? keys() { BitmapNodeSeq(objs, 0, null) }
  
  ** Index of a given bit in current objs array
  private Int index(Int bit) { bitCount(bitmap.and(bit-1)) }
}

const class BitmapNodeSeq : Seq
{
  const Int start
  const Obj?[] vals
  const Seq? nextSeq
  
  new make(Obj?[] vals, Int start, Seq? nextSeq)
  {
    this.start = start
    this.vals = vals
  }
  
  override Obj? val()
  {
    if(nextSeq != null)
      return nextSeq.val
    return vals[start]
  }
  
  override Seq? next()
  {
    if(nextSeq != null) return create(vals, start, nextSeq.next)
    return create(vals, start + 2, null)
  }
  
  private static Seq? create(Obj?[] vals, Int i, Seq? s) {
    if(s != null)
      return BitmapNodeSeq(vals, i, s)
    for(j := i; j < vals.size; j+=2) 
    {
      if(vals[j] != null)
        return BitmapNodeSeq(vals, j, null)
      MapNode? node := vals[j+1]
      if (node != null) 
      {
        nodeSeq := node.keys()
        if(nodeSeq != null) return BitmapNodeSeq(vals, j + 2, nodeSeq)
      }
    }
    return null
  }
}

internal const class ArrayNodeSeq : Seq
{
  const MapNode?[] nodes
  const Int i
  const Seq seq
  private new make(MapNode?[] nodes, Int i, Seq seq)
  {
    this.nodes = nodes
    this.i = i
    this.seq = seq
  }
  
  static Seq? create(MapNode?[] nodes, Int i, Seq? seq)
  {
    if(seq != null) return ArrayNodeSeq(nodes, i, seq)
    for(j := i; j < nodes.size; j++)
    {
      if(nodes[j] != null) 
      {
        ns := nodes[j].keys
        if(ns != null) return ArrayNodeSeq(nodes, j+1, ns)
      }
    }
    return null
  }
  
  override Obj? val() { seq.val }
  override Seq? next() { create(nodes, i, seq.next) }
}