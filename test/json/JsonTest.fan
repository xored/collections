//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
class JsonTest : Test
{
  Void testFromStr() 
  {
    json := Json.fromStr(
      Str<|{
            "foo":1,
            "bar":["a","b","c"]
           }|>)
    verifyEq(json->foo, 1)
    verifyEq(json->bar->toList, Obj?["a", "b", "c"])
  }
  Void testElem()
  {
    json := Json.fromVal(1)
    verifyEq(json.toStr, "1")
    verifyEq(json->plus(1), 2) // trap goes to json.val
  }
  
  Void testList()
  {
    json := Json.fromVal(Obj?[1,2,3])
    verifyEq(json->toList, Obj?[1,2,3])
    json = json.mutate { it->add(4) }
    verifyEq(json->toList, Obj?[1,2,3,4])
    verifyEq(json->get(2), 3)
  }
  
  private ConstJson create()
  {
    json := Json.makeWith 
    {
      it->str = "4"
      it->int = 5
      it->list = Obj?[1,2,3]
      it->map1 = Str:Obj?[:] 
      a := it->map1
      a->key1 = 4
      a->key2 = "5"
      a->key3 = Str:Obj?[:]
      b := a->key3
      b->a = 1
      b->b = 2
      b->c = 3
    }
    return json
  }

  Void testCreate()
  {
    json := create
  }
  
  Void testExcudeFields()
  {
    json := create.mutate 
    {   
      it.excludeFields |name| { name == "str" }
    }
    verifyEq(json->str, null)
  }
  
  Void testGet()
  {
    json := create
    verifyEq(json->str, "4")
    verifyEq(json->int, 5)
    verifyEq(json->list->toList, Obj?[1,2,3])
    verifyEq(json->list->get(2), 3)
    verifyEq(json->list(2), 3)
    verifyEq(json["list->2"], 3)
    verifyEq(json["str"], "4")
    verifyEq(json["int"], 5)
    verifyEq(json["list"]->toList, Obj?[1,2,3])
  }
  
  Void testSimpleMut()
  {
    json := create.mutate 
    {  
      it->list->set(2, 4)
      verifyEq(it->list(2), 4)
      it->list(2) = 3
      verifyEq(it->list(2), 3)
      it->list->add(5)
      verifyEq(it->list(3), 5)
      it->map1->key1 = 8
      verifyEq(it->map1->key1, 8)
      it["map1->key1"] = 7
      verifyEq(it->map1->key1, 7)
      it["map1->key3->c"] = 4
      verifyEq(it->map1->key3->c, 4)
      it->map1->key3->c = 5
      verifyEq(it->map1->key3->c, 5)
      mkey3 := it->map1->key3
      mkey3->a = 7
      mkey3->b = 8
      mkey3->c = 9
      verifyEq(it->map1->key3->a, 7)
      verifyEq(it->map1->key3->b, 8)
      verifyEq(it->map1->key3->c, 9)
    }
  }
  
  Void testSimpleConst()
  {
    json2 := ConstJson { it->key1 = 1 }

    json := create
    verifyEq(json->str, "4")
    verifyEq(json->int, 5)
    verifyEq(json->list->toList, Obj?[1,2,3])
    verifyEq(json->map1->key1, 4)
    verifyEq(json->map1->key2, "5")
    try
    {
      json->a = 4
    }
    catch(Err e)
    {
      verify(true)
      return
    }
    verify(false)
  }
  
  
  Void testConstMutate()
  {
    json := create
    
    json2 := json.mutate 
    { 
      it->str = "6" 
      it->map1->key1 = 5
      mkey3 := it->map1->key3
      mkey3->a = 7
      mkey3->b = 8
      mkey3->c = 9
    }

    verifyEq(json->str, "4")
    verifyEq(json2->str, "6")
    
    verifyEq(json->map1->key1, 4)
    verifyEq(json2->map1->key1, 5)

    verifyEq(json->map1->key3->a, 1)
    verifyEq(json->map1->key3->b, 2)
    verifyEq(json->map1->key3->c, 3)
    verifyEq(json2->map1->key3->a, 7)
    verifyEq(json2->map1->key3->b, 8)
    verifyEq(json2->map1->key3->c, 9)
  }

  Void testLinks()
  {
    json := Json.makeWith
    {
      it->key1 = 1
      it->key2 = 2
      it->list = [,]
      list1 := it->list
      list2 := it->list
      list1->add(1)
      // list2 link now invalid
      verifyErr(Err#) { list2.toStr }
      verifyEq(list1->size, 1)
      list2 = it->list
      verifyEq(list2->size, 1)
      list1->set(0, 2)
      // list2 link now invalid again
      verifyErr(Err#) { list2.toStr }
      verifyEq(list1->get(0), 2)
      verifyEq(it->list(0), 2)

      it->map = Str:Obj?[:]
      map1 := it->map
      map2 := it->map
      map1->a = 1
      // map2 link now invalid
      verifyErr(Err#) { map2.toStr }
      map2 = it->map
      verifyEq(map1, map2)
      map2->a = 2
      // map1 link now invalid
      verifyErr(Err#) { (map1 as Json)["a"] = 3 }
      verifyErr(Err#) { (map1 as Json).excludeFields | name | { name == "a" } }
      verifyErr(Err#) { map1.toStr }
      verifyEq(it->map, map2)
    }
  }

  Void echoNames(Json json, Str key := "")
  {
    names := json.names
    echo("$key: $names")
    names.each |v| { if (json[v] is Json) echoNames(json[v], "$key->$v")  }
  }
  
  Void testNames()
  {
    json := create
    verifyEq(json.names, Str["int", "str", "map1", "list"])
    verifyEq((json->list as Json).names, Str["0", "1", "2"])
    verifyEq((json->map1 as Json).names, Str["key1", "key2", "key3"])
    verifyEq((json->map1->key3 as Json).names, Str["a", "b", "c"])
    echoNames(json)
  }

  Void testEquals() {
    json1 := ConstJson.fromStream("{\"str\": \"sss\", \"int\": null, \"map\": {\"x\":\"x\", \"y\": 2}}".in)
    json2 := ConstJson.fromStream("{\"int\": null, \"str\": \"sss\", \"map\": {\"y\": 2, \"x\":\"x\"}}".in)
    verifyEq(json1, json2)
  }
}

