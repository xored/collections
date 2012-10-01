class VisitResult {}

class JsonVisitor : ValVisitor
{
  override final VisitResult visit(Obj? val) { super.visit(val) }
  override final VisitResult nil() { super.nil }
  override final VisitResult bool(Bool val) { super.bool(val) }
  override final VisitResult num(Num val) { super.num(val) }
  override final VisitResult str(Str val) { super.str(val) }
  
  override final protected VisitResult primitive(Obj? val)
  {
    super.primitive(val)
    return done
  }
  
  override final VisitResult map(|MapVisitor| f) 
  {
    super.map(f)
    return done
  }
  
  override final VisitResult list(|ListVisitor| f)
  {
    super.list(f)
    return done
  }
  
  virtual VisitResult done() { VisitResult() }
}

class ValVisitor
{
  protected virtual MapVisitor onMapStart() { MapVisitor() }
  protected virtual ListVisitor onListStart() { ListVisitor() }
  protected virtual Void onPrimitive(Obj? val) { }

  virtual Obj nil() { primitive(null) }
  virtual Obj bool(Bool val) { primitive(val) }
  virtual Obj num(Num val) { primitive(val) }
  virtual Obj str(Str val) { primitive(val) }
  
  virtual Obj map(|MapVisitor| f) 
  { 
    b := onMapStart
    f(b)
    b.onMapEnd
    return this
  }
  
  virtual Obj list(|ListVisitor| f)
  {
    b := onListStart
    f(b)
    b.onListEnd
    return this
  }
  
    ** Allows to visit fantom-style json 
  ** (i.e. a map of lists of maps of lists)
  virtual Obj visit(Obj? obj)
  {
    if(obj == null) return nil
    if(obj is Num) return num(obj)
    if(obj is Str) return str(obj)
    if(obj is Bool) return bool(obj)
    if(obj is List) 
    {
      return list |lv| 
      { 
        ((Obj?[]) obj).each { lv = lv.visit(it) }
      }
    }
    if(obj is Map)
    {
      return map |mv|
      {
        ((Map) obj).each |v,k| { mv = mv.key(k).visit(v) }
      }
    }
    throw ArgErr("Can't visit $obj")
  }
  protected virtual Obj primitive(Obj? val) 
  {
    onPrimitive(val)
    return this
  }
}

class MapVisitor
{
  virtual MapValVisitor key(Str val) { MapValVisitor(this) }
  protected virtual Void onMapEnd() {}
}

class MapValVisitor : ValVisitor
{
  new make(MapVisitor parent) { this.parent = parent }
  protected MapVisitor parent
  
  override final MapVisitor nil() { primitive(null) }
  override final MapVisitor bool(Bool val) { primitive(val) }
  override final MapVisitor num(Num val) { primitive(val) }
  override final MapVisitor str(Str val) { primitive(val) }
  
  override protected final MapVisitor primitive(Obj? val) 
  { 
    super.primitive(val)
    return parent
  }
  
  override final MapVisitor list(|ListVisitor| f)
  {
    super.list(f)
    return parent
  }
  
  override final MapVisitor map(|MapVisitor| f)
  {
    super.map(f)
    return parent
  }
  
  override final MapVisitor visit(Obj? val) 
  { 
    super.visit(val)
    return parent
  }
}

class ListVisitor : ValVisitor
{
  protected virtual Void onListEnd() {}
  
  override final ListVisitor nil() { super.nil }
  override final ListVisitor bool(Bool val) { super.bool(val) }
  override final ListVisitor num(Num val) { super.num(val) }
  override final ListVisitor str(Str val) { super.str(val) }
  
  protected override final ListVisitor primitive(Obj? val) 
  {
    super.primitive(val)
    return this
  }
  
  override final ListVisitor visit(Obj? val)
  {
    super.visit(val)
    return this
  }
  
  override final ListVisitor map(|MapVisitor| f)
  {
    super.map(f)
    return this
  }
  
  override final ListVisitor list(|ListVisitor| f)
  {
    super.list(f)
    return this
  }
}
