** Does not close out stream
class JsonWriter : JsonVisitor, JsonConsts
{
  new make(OutStream out) : super(null) {
    this.out = out
    this.writer = BaseWriter(out)
  }
  
  private BaseWriter writer
  
  OutStream out { private set; }
  
  override JsonVisitor nil() { writer = writer.nil; return this }
  override JsonVisitor bool(Bool val) { writer = writer.bool(val); return this }
  override JsonVisitor num(Num val) { writer = writer.num(val); return this }
  override JsonVisitor str(Str val) { writer = writer.str(val); return this }

  override JsonVisitor mapStart() { writer = writer.mapStart; return this }
  override JsonVisitor mapKey(Str key) { writer = writer.mapKey(key); return this }
  override JsonVisitor mapEnd() { writer = writer.mapEnd; return this }
  override JsonVisitor listStart() { writer = writer.listStart; return this }
  override JsonVisitor listEnd() { writer = writer.listEnd; return this }
}

internal class BaseWriter : JsonVisitor
{
  new make(OutStream out) : super(null) { this.out = out }
  
  OutStream out { private set; }
  
  override JsonVisitor nil() { primitive(null) }
  override JsonVisitor bool(Bool val) { primitive(val) }
  override JsonVisitor num(Num val) { primitive(val) }
  override JsonVisitor str(Str val) { primitive(val.toCode) }
  
  JsonVisitor primitive(Obj? obj) 
  { 
    valPrefix
    out.print(obj)
    return this
  }

  final override JsonVisitor mapStart() 
  { 
    valPrefix
    out.writeChar(JsonConsts.objectStart)
    return MapWriter(out, this)
  }
  
  override JsonVisitor listStart()
  {
    valPrefix
    out.writeChar(JsonConsts.arrayStart)
    return ListWriter(out, this)
  }
  
  
  override JsonVisitor mapEnd() { throw stateErr("Not in map") }
  override JsonVisitor mapKey(Str key) { throw stateErr("Not in map") }
  override JsonVisitor listEnd() { throw stateErr("Not in list") }
  
  protected Str prefix := ""
  protected virtual Void valPrefix() {}
  
  Err stateErr(Str msg := "Illegal state") { Err(msg) }
}

internal abstract class ContainerWriter : BaseWriter
{
  new make(OutStream out, BaseWriter parent, Int closeChar) : super(out) 
  { 
    this.parent = parent 
    this.prefix = parent.prefix + "  "
    this.closeChar = closeChar
  } 
  
  protected BaseWriter parent
  protected Bool isEmpty := true
  protected Int closeChar
  
  protected override Void valPrefix() { newline }
  
  protected Void newline()
  {
    if(!isEmpty) out.writeChar(JsonConsts.comma)
    else isEmpty = false
    out.printLine.print(prefix)
  }
  
  protected virtual JsonVisitor containerEnd()
  {
    if(!isEmpty) out.printLine.print(parent.prefix)
    out.writeChar(closeChar)
    return parent
  }
  
}

internal class MapWriter : ContainerWriter 
{
  new make(OutStream out, BaseWriter parent) : super(out, parent, JsonConsts.objectEnd) {}
  
  Bool keyVisited := false
  
  
  override protected Void valPrefix()
  {
    if(!keyVisited) throw stateErr("key must be visited first")
    keyVisited = false
    out.writeChar(JsonConsts.colon).writeChar(' ')
  }
  
  override JsonVisitor mapKey(Str key) 
  {
    if(keyVisited) throw stateErr("key is already visited")
    keyVisited = true
    newline
    out.print(key.toCode)
    return this
  }
  
  override JsonVisitor mapEnd()
  {
    if(keyVisited) throw stateErr("Can't close map when key visited")
    return containerEnd
  }

}

internal class ListWriter : ContainerWriter
{
  new make(OutStream out, BaseWriter parent) : super(out, parent, JsonConsts.arrayEnd) {}
  
  override JsonVisitor listEnd() { containerEnd }
}