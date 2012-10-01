
class JsonWriter : JsonVisitor, BaseWriter
{
  new make(OutStream out) 
  {
    this.out = out
  }
  
  override OutStream out
  protected override Str prefix := ""
  
  override VisitResult primitive(Obj? val)
  {
    printPrimitive(val)
    return super.primitive(val)
  }
  
  override protected MapVisitor mapStart()
  {
    printMapStart
    return MapWriter(out, this)
  }
  
  override protected ListVisitor listStart()
  {
    printListStart
    return ListWriter(out, this)
  }
}

mixin BaseWriter
{
  protected abstract Str prefix()
  abstract OutStream out

  protected Void printPrimitive(Obj? val)
  {
    out.print(val is Str ? ((Str)val).toCode : val)
  }
  
  protected Void printListStart() { out.writeChar(JsonConsts.arrayStart) }
  protected Void printMapStart() { out.writeChar(JsonConsts.objectStart) }
}

mixin BaseContainer : BaseWriter
{
  protected abstract Bool isEmpty()
  protected abstract Void notEmpty()
  protected abstract Int closeChar()
  protected abstract BaseWriter parent()
  
  protected Void newline()
  {
    if(!isEmpty) out.writeChar(JsonConsts.comma)
    else notEmpty
    out.printLine.print(prefix)
  }

  protected Void closeContainer()
  {
    if(!isEmpty) out.printLine.print(parent.prefix)
    out.writeChar(closeChar)
  }
}

internal class MapWriter : MapVisitor, BaseContainer
{
  override protected Str prefix
  override OutStream out
  override protected Bool isEmpty := true
  override protected Void notEmpty() { isEmpty = false }
  private MapValWriter valWriter 
  override protected BaseWriter parent
  override protected Int closeChar := JsonConsts.objectEnd
  new make(OutStream out, BaseWriter parent) 
  {
    this.out = out
    this.prefix = parent.prefix + "  "
    this.valWriter = MapValWriter(out, this)
    this.parent = parent
  }
  
  override protected Void mapEnd() { closeContainer }
  
  override MapValVisitor key(Str val)
  {
    newline
    out.print(val.toCode).writeChar(JsonConsts.colon).writeChar(' ')
    return valWriter
  }
}

internal class MapValWriter : MapValVisitor, BaseWriter
{
  new make(OutStream out, MapWriter parent) : super(parent) 
  {
    this.out = out
    this.prefix = parent.prefix
  }
  override OutStream out
  override protected Str prefix

  override protected Void primitive(Obj? val) 
  { 
    printPrimitive(val) 
  }
  
  override protected ListVisitor listStart()
  {
    printListStart
    return ListWriter(out, this)
  }
  
  override protected MapVisitor mapStart()
  {
    printMapStart
    return MapWriter(out, this)
  }

}

internal class ListWriter : ListVisitor, BaseContainer
{
  override OutStream out
  override protected Str prefix
  override protected BaseWriter parent
  override protected Bool isEmpty := true
  override protected Void notEmpty() { isEmpty = false }
  override protected Int closeChar := JsonConsts.arrayEnd
  
  new make(OutStream out, BaseWriter parent)
  {
    this.prefix = parent.prefix + "  "
    this.out = out
    this.parent = parent
  }
  
  override This primitive(Obj? val)
  {
    newline
    printPrimitive(val)
    return this
  }
  
  override protected MapVisitor mapStart()
  {
    newline
    printMapStart
    return MapWriter(out, this)
  }
  
  override protected ListVisitor listStart()
  {
    newline
    printListStart
    return ListWriter(out, this)
  }
  
  override protected Void listEnd() 
  {
    closeContainer
  }
}
