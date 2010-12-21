//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ilya Sherenkov 21.12.2010 - Initial Contribution
//


**
**
**
class SpeedTest : Test
{
  Void echoTimeFrom(Duration d, Str s := "")
  {
    echo("$s${(Duration.now - d).toMillis}ms")
  }
  
  Void notestAddSpeed() 
  {
    echo("*** Test of \"add\".")
    doAddN(10)
    doAddN(100)
    doAddN(100)
    doAddN(1000)
    doAddN(10000)
    doAddN(100000)
    doAddN(1000000)
  }
  
  Void verifyAfterAddN(ConstColl coll, Int n)
  {
    verifyEq(coll->size, n)
    verifyEq(coll.reduce(0) |Int r, Int v -> Int | { r+=v }, (n-1) * n / 2)
  }
  
  Void doAddN(Int n)
  {
    cList := ConstList.empty
    fList := [,]
    fCList := [,]
    fMap := [:]
    fCMap := [:]
    hashSet := ConstHashSet()
    treeSet := ConstTreeSet()

    echo("*** n=$n ")
    d := Duration.now
    n.times { cList = cList.add(it) }
    echoTimeFrom(d, "ConstList: ")
    verifyAfterAddN(cList, n)
    
    d = Duration.now
    n.times { fList.add(it) }
    echoTimeFrom(d, "list: ")

    if (n<=10000)
    {
      d = Duration.now
      n.times { fCList = fCList.dup.add(it).toImmutable }
      echoTimeFrom(d, "list+toImmutable: ")
    }
    else { echo("list+toImmutable sucks") }
    
    d = Duration.now
    n.times { fMap.add(it, it) }
    echoTimeFrom(d, "map: ")

    if (n<=10000)
    {
      d = Duration.now
      n.times { fCMap = fCMap.dup.add(it, it).toImmutable }
      echoTimeFrom(d, "map+toImmutable: ")
    }
    else { echo("map+toImmutable sucks") }

    d = Duration.now
    n.times { hashSet = hashSet.add(it) }
    echoTimeFrom(d, "ConstHashSet: ")
    verifyAfterAddN(hashSet, n)

    d = Duration.now
    n.times { treeSet = treeSet.add(it) }
    echoTimeFrom(d, "ConstTreeSet: ")
    verifyAfterAddN(treeSet, n)
  }

  
  Void notestRemoveSpeed() 
  {
    echo("*** Test of \"remove\".")
    doRemoveN(10)
    doRemoveN(100)
    doRemoveN(100)
    doRemoveN(1000)
    doRemoveN(10000)
    doRemoveN(100000)
    doRemoveN(1000000)
  }

  Void verifyAfterRemove(ConstColl coll, Int n)
  {
    verifyEq(coll->size, n/2)
    verifyEq(coll.reduce(0) |Int r, Int v -> Int | { r+=v }, (n-2) * n/4)
  }

  Void doRemoveN(Int n)
  {
    verify(n.isEven) 
    
    cList := ConstList.fromList((0..<n).toList)
    echo("*** n=$n, removing n/2 odd elements ")
    d := Duration.now
    (n/2).times { cList = cList.removeAt(it + 1) }
    echoTimeFrom(d, "ConstList: ")
    verifyAfterRemove(cList, n) // was stack overflow on n>1000
    
    if (n<=100000)
    {
      fList := (0..<n).toList
      d = Duration.now
      (n/2).times { fList.removeAt(it + 1) }
      echoTimeFrom(d, "list: ")
      verifyEq(fList.size, n / 2)
    }
    else { echo("list sucks") }

    if (n<=10000)
    {
      fCList := (0..<n).toList
      d = Duration.now
      (n/2).times { fCList = fCList.dup; fCList.removeAt(it + 1); fCList = fCList.toImmutable }
      echoTimeFrom(d, "list+toImmutable: ")
      verifyEq(fCList.size, n / 2)
    }
    else { echo("list+toImmutable sucks") }
    
    [Int:Int] fMap := [:]
    n.times { fMap.add(it, it) }
    d = Duration.now
    (n/2).times { fMap.remove(it*2 + 1) }
    echoTimeFrom(d, "map: ")
    verifyEq(fMap.size, n / 2)

    if (n<=10000)
    {
      [Int:Int] fCMap := [:]
      n.times { fCMap.add(it, it) }
      d = Duration.now
      (n/2).times { fCMap = fCMap.dup; fCMap.remove(it*2 + 1); fCMap = fCMap.toImmutable }
      echoTimeFrom(d, "map+toImmutable: ")
      verifyEq(fCMap.size, n / 2)
    }
    else { echo("map+toImmutable sucks") }

    hashSet := ConstHashSet()
    n.times { hashSet = hashSet.add(it) }
    d = Duration.now
    (n/2).times { hashSet = hashSet.remove(it*2 + 1) }
    echoTimeFrom(d, "ConstHashSet: ")
    verifyAfterRemove(hashSet, n)

    treeSet := ConstTreeSet()
    n.times { treeSet = treeSet.add(it) }
    d = Duration.now
    (n/2).times { treeSet = treeSet.remove(it*2 + 1) }
    echoTimeFrom(d, "ConstTreeSet: ")
    verifyAfterRemove(treeSet, n)
  }

  Void testRemoveRandomSpeed() 
  {
    echo("*** Test of \"remove\" at random.")
    doRemoveRandomN(10)
    doRemoveRandomN(100)
    doRemoveRandomN(100)
    doRemoveRandomN(1000)
    doRemoveRandomN(10000)
    doRemoveRandomN(100000)
    doRemoveRandomN(1000000)
  }
  Void doRemoveRandomN(Int n)
  {
    verify(n.isEven) 
    
    cList := ConstList.fromList((0..<n).toList)
    echo("*** n=$n, removing n/2 random elements ")
    
    d := Duration.now
    (n/2).times { cList = cList.removeAt(Int.random(0..<n-it)) }
    echoTimeFrom(d, "ConstList: ")
    verifyEq(cList.size, n / 2)
    echo("CList sum = " + cList.reduce(0) |Int r, Int v -> Int | { r+=v })
    
    if (n<=100000)
    {
      fList := (0..<n).toList
      d = Duration.now
      (n/2).times { fList.removeAt(Int.random(0..<n-it)) }
      echoTimeFrom(d, "list: ")
      verifyEq(fList.size, n / 2)
    }
    else { echo("list sucks") }

    if (n<=10000)
    {
      fCList := (0..<n).toList
      d = Duration.now
      (n/2).times { fCList = fCList.dup; fCList.removeAt(Int.random(0..<n-it)); fCList = fCList.toImmutable }
      echoTimeFrom(d, "list+toImmutable: ")
      verifyEq(fCList.size, n / 2)
    }
    else { echo("list+toImmutable sucks") }
    
    [Int:Int] fMap := [:]
    n.times { fMap.add(it, it) }
    d = Duration.now
    (n/2).times { fMap.remove(Int.random(0..<n)) }
    echoTimeFrom(d, "map: ")
    //verifyEq(fMap.size, n / 2)

    if (n<=10000)
    {
      [Int:Int] fCMap := [:]
      n.times { fCMap.add(it, it) }
      d = Duration.now
      (n/2).times { fCMap = fCMap.dup; fCMap.remove(Int.random(0..<n)); fCMap = fCMap.toImmutable }
      echoTimeFrom(d, "map+toImmutable: ")
      //verifyEq(fCMap.size, n / 2)
    }
    else { echo("map+toImmutable sucks") }

    hashSet := ConstHashSet()
    n.times { hashSet = hashSet.add(it) }
    d = Duration.now
    (n/2).times { hashSet = hashSet.remove(Int.random(0..<n)) }
    echoTimeFrom(d, "ConstHashSet: ")
    //verifyEq(hashSet.size, n / 2)

    treeSet := ConstTreeSet()
    n.times { treeSet = treeSet.add(it) }
    d = Duration.now
    (n/2).times { treeSet = treeSet.remove(Int.random(0..<n)) }
    echoTimeFrom(d, "ConstTreeSet: ")
    //verifyEq(treeSet.size, n / 2)
  }
  
}
