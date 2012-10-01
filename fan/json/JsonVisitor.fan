class VisitResult {}

class JsonVisitor : ValVisitor
{
  virtual VisitResult nil() { primitive(null) }
  virtual VisitResult bool(Bool val) { primitive(val) }
  virtual VisitResult num(Num val) { primitive(val) }
  virtual VisitResult str(Str val) { primitive(val )}
  
  protected virtual VisitResult primitive(Obj? val) { done }

  virtual VisitResult map(|MapVisitor| f) 
  {
    visitMap(f)
    return VisitResult()
  }
  
  virtual VisitResult list(|ListVisitor| f)
  {
    visitList(f)
    return VisitResult()
  }
  
  virtual VisitResult done() { VisitResult() }
}

mixin ValVisitor
{
  protected virtual MapVisitor mapStart() { MapVisitor() }
  protected virtual ListVisitor listStart() { ListVisitor() }
  
  protected Void visitMap(|MapVisitor| f)
  {
    b := mapStart
    f(b)
    b.mapEnd
  }
  
  protected Void visitList(|ListVisitor| f)
  {
    b := listStart
    f(b)
    b.listEnd
  }
}

class MapVisitor
{
  virtual MapValVisitor key(Str val) { MapValVisitor(this) }
  protected virtual Void mapEnd() {}
}

class MapValVisitor : ValVisitor
{
  new make(MapVisitor parent) { this.parent = parent }
  protected MapVisitor parent
  
  virtual MapVisitor nil() { primitive(null); return parent }
  virtual MapVisitor bool(Bool val) { primitive(val); return parent }
  virtual MapVisitor num(Num val) { primitive(val); return parent }
  virtual MapVisitor str(Str val) { primitive(val); return parent }
  
  protected virtual Void primitive(Obj? val) {}
  virtual MapVisitor list(|ListVisitor| f)
  {
    visitList(f)
    return parent
  }
  
  virtual MapVisitor map(|MapVisitor| f)
  {
    visitMap(f)
    return parent
  }
}

class ListVisitor : ValVisitor
{
  protected virtual Void listEnd() {}
  
  virtual This nil() { primitive(null) }
  virtual This bool(Bool val) { primitive(val) }
  virtual This num(Num val) { primitive(val) }
  virtual This str(Str val) { primitive(val )}
  
  protected virtual This primitive(Obj? val) { this }

  virtual ListVisitor map(|MapVisitor| f)
  {
    visitMap(f)
    return this
  }
  
  virtual ListVisitor list(|ListVisitor| f)
  {
    visitList(f)
    return this
  }
}
