class BuildResult {}

class JsonBuilder : ValBuilder
{
  virtual BuildResult nil() { done }
  virtual BuildResult bool(Bool val) { done }
  virtual BuildResult num(Num val) { done }
  virtual BuildResult str(Str val) { done }
  
  virtual BuildResult map(|MapBuilder| f) 
  {
    buildMap(f)
    return BuildResult()
  }
  
  virtual BuildResult list(|ListBuilder| f)
  {
    buildList(f)
    return BuildResult()
  }
  
  virtual BuildResult done() { BuildResult() }
}

mixin ValBuilder
{
  protected virtual MapBuilder mapStart() { MapBuilder(this) }
  protected virtual ListBuilder listStart() { ListBuilder(this) }
  
  protected Void buildMap(|MapBuilder| f)
  {
    b := mapStart
    f(b)
    b.mapEnd
  }
  
  protected Void buildList(|ListBuilder| f)
  {
    b := listStart
    f(b)
    b.listEnd
  }
}

mixin SubBuilder
{
  protected abstract JsonBuilder parent()
}

class MapBuilder : SubBuilder 
{
  new make(ValBuilder parent) { this.parent = parent }
  override protected JsonBuilder parent
  
  virtual MapValBuilder key(Str val) { MapValBuilder(this) }
  protected virtual JsonBuilder mapEnd() { parent }
}

class MapValBuilder : ValBuilder
{
  new make(MapBuilder parent) { this.parent = parent }
  protected MapBuilder parent
  
  virtual MapBuilder nil() { parent }
  virtual MapBuilder bool(Bool val) { parent }
  virtual MapBuilder num(Num val) { parent }
  virtual MapBuilder str(Str val) { parent }
  
  virtual MapBuilder list(|ListBuilder| f)
  {
    buildList(f)
    return parent
  }
  
  virtual MapBuilder map(|MapBuilder| f)
  {
    buildMap(f)
    return parent
  }
}

class ListBuilder : SubBuilder, ValBuilder
{
  new make(ValBuilder parent) { this.parent = parent }
  override protected JsonBuilder parent
  protected virtual JsonBuilder listEnd() { parent }
  
  virtual This nil() { this }
  virtual This bool(Bool val) { this }
  virtual This num(Num val) { this }
  virtual This str(Str val) { this }
  
  virtual ListBuilder map(|MapBuilder| f)
  {
    buildMap(f)
    return this
  }
  
  virtual ListBuilder list(|ListBuilder| f)
  {
    buildList(f)
    return this
  }
}
