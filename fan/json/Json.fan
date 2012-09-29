//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
using util

**
** Mixin for a JSON object. 
** Static construction methods return ConstJson objects, witch are the only implementation to
** work with.
**    json := Json.makeWith 
**    {
**      it->str = "4"
**      it->int = 5
**      it->list = Obj?[1,2,3]
**      it->map1 = Str:Obj?[:] 
**      a := it->map1
**      a->key1 = 4
**      a->key2 = "5"
**      a->key3 = Str:Obj?[:]
**      b := a->key3
**      b->a = 1
**      b->b = 2
**      b->c = 3
**    }
** 
** To make changes for a ConstJson object a `#mutate` method is used.
** 
**    json := json.mutate 
**    {
**      it->str = "1"
**      it->int = 3
**    }
**  
mixin Json
{
  **
  ** JSON inner content
  ** 
  internal abstract Obj? val()

  internal abstract Obj? getFromContent(Str name)
  internal abstract Obj? setToContent(Str name, Obj? newVal)
  
  **
  ** types, that only can be used in JSON:
  ** 
  private static const Type[] allowed := [Bool#, Int#, Float#, Str#, [Str:Obj?]#, Obj?[]#, ConstMap#, ConstList#, ConstJson#, Jsonable#] 
  **
  ** Check that arg is one of the follow types, that only can be used in JSON:
  **   - null
  **   - Bool
  **   - Int
  **   - Float
  **   - Str
  **   - Str:Obj?
  **   - Obj?[]
  ** 
  protected static Void checkArgType(Obj? arg)
  {
    if ( arg != null && !allowed.any { arg.typeof.fits(it) } )
          throw ArgErr("${arg.typeof} is not an acceptable type for JSON.")
  }

  **
  ** converts Map or List to ConstMap/ConstList
  ** 
  protected static Obj? convertVal(Obj? val)
  {
    if (val is Str:Obj?)
      return ConstHashMap.empty.addAllMap( (val as Str:Obj?).map |v| { v = convertVal(v) } )
    else if (val is Obj?[])
      return ConstList.empty.addAll( (val as Obj?[]).map |v| { v = convertVal(v) } )
    else 
      return val
  }

  **
  ** Creates an empty JSON object
  ** 
  static ConstJson makeEmpty() { fromVal(Str:Obj?[:]) }
  **
  ** Creates a JSON object from stream
  ** 
  static ConstJson fromStream(InStream in) { fromVal(JsonInStream(in).readJson) }
  **
  ** Creates a JSON object from string
  ** 
  static ConstJson fromStr(Str str) 
  { 
    if(str == "\"") {
      brak := true
    }
    return fromStream(str.in) 
    
  }
  **
  ** Creates a JSON object from a value given
  ** 
  static ConstJson fromVal(Obj? val) 
  { 
    checkArgType(val)
    return ConstJson.makeFromVal(convertVal(val))
  }
  
**
** Creates a JSON object using it-block
**    json := Json.makeWith 
**    {
**      it->str = "4"
**      it->int = 5
**      it->list = Obj?[1,2,3]
**      it->map1 = Str:Obj?[:] 
**      a := it->map1
**      a->key1 = 4
**      a->key2 = "5"
**      a->key3 = Str:Obj?[:]
**      b := a->key3
**      b->a = 1
**      b->b = 2
**      b->c = 3
**    }
** 
  static ConstJson makeWith(|Json| f)
  {
    ConstJson.make(f)
  }
  
  override Str toStr() 
  {
    buf := StrBuf()
    toStream(buf.out)
    return buf.toStr
  }
  
  virtual Void toStream(OutStream out) { JsonPrinter().writeJson(out, val) }


  override Int hash()
  {
    val.hash
  }
  
  virtual Bool equiv(Obj? other) 
  { 
    other is Json ? this.val == (other as Json).val : false
  }

  override Bool equals(Obj? other) 
  { 
    typeof() == other.typeof ? this.equiv(other) : false
  }

  
  **
  ** Checks when a "list(index)" call trapped and converts it to a get or set accordinly.  
  ** 
  private Obj? checkListIndex(Json list, Str name, Obj?[]? args)
  {
    args[0] = convertVal(args[0]) // Here we do a deep list content check
    if (!(args.size == 1 && (args[0] is ConstList || args[0] is Int)) &&
        !(args.size == 2 && args[1] is Int)) throw ArgErr("Can't call method $name on JSON object.")

    if (args.size == 1) 
      if (args[0] is ConstList) 
        return setToContent(name, args[0]) 
      else
        return list->get(args[0])
    else
    {
      return list->set(args[0], convertVal(args[1]))
    }
  }

  **
  ** trap override for a JSON operations
  ** 
  override Obj? trap(Str name, Obj?[]? args := null)
  {
    if (val is ConstList) return ListJsonTrapper(this).doTrap(name, args)
    if (val isnot ConstMap) return val.trap(name, args) 
    if (args?.isEmpty ?: true) return getFromContent(name)
    obj := getFromContent(name) 
    if (obj is Json && (obj as Json).val is ConstList) return checkListIndex(obj, name, args)
    if (args.size > 1) throw ArgErr("Can't call method $name on JSON object.")
    checkArgType(args[0])
    return setToContent(name, convertVal(args[0]))
  }

  **
  ** Splits path to a JSON inner value
  ** 
  protected Str[] splitJsonPath(Str path)
  {
    path.replace("->", 13.toChar).split(13)
  }
  
  **
  ** Finds target of the last trap for a path given
  ** 
  protected Obj? findTrapTarget(Str[] pathList)
  {
    Obj? target := this
    for (i:=0;i<pathList.size;i++ )
    {
      target = target.trap(pathList[i], Obj?[,])
    }
    return target
  }
  
  **
  ** Get value by a path string separated by a "->"
  ** 
  **   path := "platform->plugins->30->name"
  **   name := json[path]
  ** 
  @Operator Obj? get(Str path, Obj? defval := null) 
  { 
    return findTrapTarget(splitJsonPath(path))
  }
  
  **
  ** Set value by a path string separated by a "->"
  **
  **   path := "platform->plugins->30->name"
  **   json := json.mutate { it[path] = "New Name" } 
  ** 
  @Operator abstract This set(Str path, Obj? newVal)


  abstract Void each(|Str, Obj?| fn)
  
  virtual Str:Obj? toMap() 
  {
    result := [Str:Obj?][:]
    each |k, v| { result[k] = v }
    return result
    
  }

  **
  ** Remove fields from an object JSON by condition given
  ** 
  **   json := json.mutate { it.excludeFields |name| { name == "oldName" } }
  ** 
  abstract This excludeFields(|Str->Bool| filter)
  
  **
  ** Lists children names of a complex JSON 
  ** 
  virtual Str[] names()
  {
    if (val is ConstMap)
      return (val as ConstMap).reduce(Str[,]) | Str[] r, MapEntry v, i | { r.add(v.key) }
    else if (val is ConstList)
      return (val as ConstList).reduce(Str[,]) | Str[] r, v, Int i | { r.add(i.toStr) }
    else
      return Str[,]
  }
  
  virtual Bool isList() { val is ConstList || val is List }
}

internal class MutableJson: Json
{
  internal override Obj? val
  **
  ** MutableJson address inside a root MutableJson
  ** Used for tracking changes
  ** 
  internal Str address
  
  **
  ** Function for updating parent MutableJson object after updating current MutableJson.
  ** It passes up new Obj? val and Int version values.
  ** Finally all this ends at root.
  ** 
  protected |Obj?, Int->Void| updateParent
  **
  ** Root MutableJson object (it accumulates all changes of its children)
  ** 
  protected RootMutableJson root
  **
  ** This MutableJson version = Root MutableJson version at this MutableJson creation moment
  ** 
  internal Int version := 0
  **
  ** Changes version number of MutableJson, therefore child links made before this operation 
  ** will become invalid. The main problem now is that actually we are not containing MutableJson objects
  ** inside each other, they are just on-the-fly wrapper around get/set operations from a first one root MutableJson.
  ** Therefore we need to track the root witch has the map of version requirements 
  ** and increase version requirement for this address.  
  ** It will prevent some nasty errors that might happen due to invalid links.  
  ** 
  internal Void increaseVersionRequirement()
  {
    root.increaseVersionForAddress(address)
    version = root.requiredVersionFor(address)
  }

  protected new makeFromVal(Obj? val, RootMutableJson root, Str address, Int version, |Obj?, Int->Void| updateParent) 
  {
    this.val = val
    this.root = root 
    this.address = address 
    this.version = version
    this.updateParent = updateParent
  }
  
  protected Obj? wrapIfNeeded(Obj? getVal, Str address, |Obj?, Int->Void| updateParent)
  {
    (getVal is ConstMap || getVal is ConstList) ? MutableJson.makeFromVal(getVal, root, address, version, updateParent) : getVal 
  }
  
  internal Str createAddressFor(Str name) { (address == "" ? "" : address + "->" ) + name }
  
  internal override Obj? getFromContent(Str name)
  {
    if (val is ConstMap)
      return val->containsKey(name) ? 
        wrapIfNeeded(val->get(name), createAddressFor(name), 
          |newVal, newVersion| 
          { 
            version = newVersion
            setToContent("", val->set(name, newVal))
          }) : null
    else if (val is ConstList)
      return wrapIfNeeded(val->get(name.toInt), createAddressFor(name),
        |newVal, newVersion| 
        { 
          version = newVersion
          setToContent("", val->set(name.toInt, newVal)) 
        })
    else 
      throw ArgErr("Not a complex JSON.")
  }

  **
  ** Checks if this MutableJson link is valid
  ** 
  virtual Void validate()
  {
    if (version < root.requiredVersionFor(address))
      throw Err("This child link object at \"$address\" (v.$version) is invalidated after a parent JSON object change.")
  }
  **
  ** Updates parent using closure provided at creation 
  ** 
  internal Void doUpdateParent(Obj? val)
  {
    updateParent(val, version)
  }
  
  override Obj? trap(Str name, Obj?[]? args := null)
  {
    validate
    return Json.super.trap(name, args)
  }

  override Str toStr()
  {
    validate
    return Json.super.toStr
  }

  override Void toStream(OutStream out) 
  {
    validate
    return Json.super.toStream(out)
  }
  
  override Int hash()
  {
    validate
    return Json.super.hash
  }
  
  override Bool equiv(Obj? other) 
  { 
    validate
    return Json.super.equiv(other)
  }

  override Bool equals(Obj? other) 
  { 
    validate
    return Json.super.equals(other)
  }

  override Str[] names()
  { 
    validate
    return Json.super.names
  }

  internal override Obj? setToContent(Str name, Obj? newVal)
  {
    if (name=="")
    {
      val = newVal
      doUpdateParent(val)
      return this
    }
    else if (val is ConstList || val is ConstMap)
    {
      increaseVersionRequirement
      val = val->set(name, newVal)
      doUpdateParent(val)
      return this
    }
    else
      throw ArgErr("Only complex type MutableJson can operate with its values.")
  }

  @Operator override This set(Str path, Obj? newVal)
  {
    list := splitJsonPath(path)
    setName := list[-1]
    list.removeAt(-1)
    return (MutableJson) findTrapTarget(list).trap(setName, [newVal])
  }
 
  override Void each(|Str, Obj?| fn) {
    validate
    if (val is ConstMap)
    {
      (val as ConstMap).each |MapEntry m| { fn(m.key, m.val) }
      return
    }
    throw ArgErr("Can iterate fields of an object JSON only.")
  }

 
  override This excludeFields(|Str->Bool| filter)
  {
    validate
    if (val is ConstMap)
    {
      oldVal := val
      (oldVal as ConstMap).each |MapEntry m| 
      { 
        if (filter(m.key))
        {
          root.increaseVersionForAddress(createAddressFor(m.key)) 
          version = root.requiredVersionFor(createAddressFor(m.key))
        }
      }
      setToContent("", (val as ConstMap).reduce(ConstHashMap.empty) |ConstMap r, MapEntry m, i| { filter(m.key) ? r : r.set(m.key, m.val) })
      return this
    }
    throw ArgErr("Can exclude fields from an object JSON only.")
  }
}

**
** Root mutable Json class
** 
internal class RootMutableJson : MutableJson
{
  new make(Obj? val) : super.makeFromVal(val, this, "", 0, | newVal | { }) { versionInfo = Str:Int["" : 0] }
  ** 
  ** Version info table for the parts of JSON
  ** It is planned to be more useful way to track child list JSON version changes.
  ** If we have a JSON 
  **    { rootlist: [ [0,1,2], [3,4,5] ] }
  ** first of all we have in this map
  **   ["": 0]  
  ** and make changes to rootlist->1 then version will be increased only for it
  **   ["": 0, "rootlist->1": 1]
  ** and previous links Jsons for rootlist and rootlist->0 should remain valid (they had version = 0).
  ** Then we make changes to rootlist.
  ** Now we need to invalidate all references to its sublists too.
  ** So we eliminate all subaddresses from list and change map to
  **   ["": 0, "rootlist": 2]
  ** i.e. version number is increased after every change.
  ** So, we change rootlist->0 and get
  **   ["": 0, "rootlist": 2, "rootlist->0" : 3]
  ** Then we decide to do something weird to root object and get
  **   ["": 4]
  ** And so on.
  ** The own root version number is changed on every change, so the links made from it
  ** are keeping to be "fresh", so this map value has minimal version requitement to access the address at key and below.
  **    
  private Str:Int versionInfo
  **
  ** Used as increasing version number sequence.
  ** Although, we could use "version" slot for that purpose, even that it will be updated by updateParent chain calls,
  ** its value expected to be exactly the same as versionInfoNum. 
  ** But still, using independent private slot expected to be more hard to crash due to some bugs.
  ** 
  private Int versionInfoNum
  override Void validate() {  } // root is always valid

  **
  ** Version for address increment
  ** 
  Void increaseVersionForAddress(Str address)
  {
    // remove all subaddresses
    versionInfo = versionInfo.exclude |v, k| { k.startsWith(address)  }
    versionInfo[address] = ++versionInfoNum 
  }
  
  **
  ** Version checking for address
  ** 
  Int requiredVersionFor(Str address)
  {
    if (versionInfo.containsKey(address)) 
      return versionInfo[address]
    else
    {
      // need to return the parent path info
      path := splitJsonPath(address)
      while (path.size > 0)
      {
        path.removeAt(-1)
        checkPath := path.join("->")
        if (versionInfo.containsKey(checkPath))  return versionInfo[checkPath]
      }
    }
    return versionInfo[""]
  }
}

**
** Constant JSON object.
** 
const class ConstJson: Json
{
  internal override const Obj? val
  
  private Json toMutable()
  {
    RootMutableJson(val)
  }
  
**   
** Changes JSON object 
**   json := json.mutate 
**    {
**      it->str = "1"
**      it->int = 3
**    }
** 
  ConstJson mutate(|Json| f)
  {
    json := toMutable
    f(json)
    return ConstJson.makeFromVal(json.val)
  }
  
  protected Obj? wrapIfNeeded(Obj? getVal)
  {
    (getVal is ConstMap || getVal is ConstList) ? ConstJson.makeFromVal(getVal) : getVal 
  }
  
  internal override Obj? getFromContent(Str name)
  {
    if (val is ConstMap)
      return val->containsKey(name) ? 
        wrapIfNeeded(val->get(name)) : null
    else if (val is ConstList)
      return wrapIfNeeded(val->get(name.toInt))
    else 
      throw ArgErr("Not a complex JSON.")
  }

  internal override Obj? setToContent(Str name, Obj? newVal)
  {
    throw ArgErr("Can't set field for const JSON object")
  }
  
  internal new makeFromVal(Obj val) 
  {
    this.val = val
  }

** 
** Direct way to create a ConstJson
**   json := ConstJson 
**    {
**      it->str = "4"
**      it->int = 5
**      it->list = Obj?[1,2,3]
**      it->map1 = Str:Obj?[:] 
**      a := it->map1
**      a->key1 = 4
**      a->key2 = "5"
**      a->key3 = Str:Obj?[:]
**      b := a->key3
**      b->a = 1
**      b->b = 2
**      b->c = 3
**    }
** 
 new make(|Json| f)
  {
    json := makeEmpty.toMutable
    f(json)
    this.val = json.val 
  }
  
  @Operator override This set(Str path, Obj? newVal)
  {
    throw ArgErr("Can't set field for const JSON object")
  }

  override Void each(|Str, Obj?| fn) {
    if (val is ConstMap)
    {
      (val as ConstMap).each |MapEntry m| { fn(m.key, wrapIfNeeded(m.val)) }
      return
    }
    throw ArgErr("Can iterate fields of an object JSON only.")
  }

  override This excludeFields(|Str->Bool| filter)
  {
    throw ArgErr("Can't set field for const JSON object")
  }
}

**
** traps calls to a Json with a ConstList content 
** 
internal class ListJsonTrapper
{
  private Json json
  new make(Json json) { this.json = json }

  const Str[] simple := ["add", "removeAt", "set", "insert", "push",
    "take", "drop", "addAll", "sort"]
  
  private Json simpleTrap(Str name, Obj?[]? args) 
  { 
    newVal := json.val.trap(name, args)
    (json as MutableJson).increaseVersionRequirement
    json.setToContent("", newVal)
    return json
  }

  const Str[] allowed := ["first", "last", "get", "peek", "size",
    "each", "eachWhile", "eachrWhile", "exclude", "map", "findAll", "toList", "reduce"]
    
  Obj? doTrap(Str name, Obj?[]? args)
  {
    if (simple.any { name == it }) 
    {
      return simpleTrap(name, args)
    }
    else if (allowed.any { name == it }) 
    {
      return trap(name, args)
    }
    else if (Int.fromStr(name, 10, false) != null)
    {
      // get/set trap
      if (args.isEmpty)
        return get(name.toInt)
      else
        return simpleTrap(name, args)
    }
    else 
      throw UnknownSlotErr("Can't call method $name on JSON list object.")
  }
  
  Obj? last()
  {
    return json.getFromContent(((json.val as ConstList).size - 1).toStr)
  }
  
  Obj? peek() { last }
 
  Obj? get(Int index)
  {
    json.getFromContent(index.toStr)
  }
 
  Obj? size()
  {
    (json.val as ConstList).size
  }

  Obj? first() 
  {
    json.getFromContent("0")
  }
  
  Obj? eachWhile(|Obj?, Int->Obj?| f)
  {
    (json.val as ConstList).eachWhile |v, i| { f(json.getFromContent(i.toStr), i) }
  }
  
  Obj? eachrWhile(|Obj?, Int->Obj?| f)
  {
    (json.val as ConstList).eachrWhile |v, i| { f(json.getFromContent(i.toStr), i) }
  }  
  
  Void each(|Obj?, Int| f)
  {
    (json.val as ConstList).each |v, i| { f(json.getFromContent(i.toStr), i) }
  }
  
  Json exclude(|Obj?, Int -> Bool| f) 
  {  
    newVal := (json.val as ConstList).exclude |v, i| { f(json.getFromContent(i.toStr), i) }
    (json as MutableJson).increaseVersionRequirement
    json.setToContent("", newVal)
    return json
  }

  Obj? reduce(Obj? init, |Obj? r, Obj? v, Int i->Obj?| c)
  {
    (json.val as ConstList).reduce(init) |r, v, i| { c(r, json.getFromContent(i.toStr), i) }
  }
  
  ConstJson map(|Obj?, Int -> Obj?| f)  
  {  
    newVal := (json.val as ConstList).map |v, i| { f(json.getFromContent(i.toStr), i) }
    return ConstJson.makeFromVal(newVal)
  }

  Obj?[] findAll(|Obj?, Int -> Bool| f)
  {
    (json.val as ConstList).reduce(Obj?[,])
    |Obj?[] r, v, i| 
    { 
      v = json.getFromContent(i.toStr)
      if (f(v, i)) r = r.add(v) 
      return r
    } 
  }
  
  Obj?[] toList(Type of := Obj?#)
  {
    result := List(of, size)
    each |v| { result.add(v) }
    return result
  }
}

**
** JsonToken represents the tokens in JSON.
**
@Js
internal class JsonToken
{
  internal static const Int objectStart := '{'
  internal static const Int objectEnd := '}'
  internal static const Int colon := ':'
  internal static const Int arrayStart := '['
  internal static const Int arrayEnd := ']'
  internal static const Int comma := ','
  internal static const Int quote := '"'
  internal static const Int grave := '`'
}