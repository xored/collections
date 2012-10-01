class BuildResult : VisitResult
{
  new make(Obj? result) { this.result = result }
  Obj? result
}

class JsonBuilder : JsonVisitor
{
  protected BuildResult result := BuildResult(null)
  
  override protected Void onPrimitive(Obj? val)
  {
    result.result = val
  }
  
  override MapVisitor onMapStart() { MapBuilder { result.result = it } }

  override ListVisitor onListStart() { ListBuilder { result.result = it } }
  
  override BuildResult done() { result }
}

class MapBuilder : MapVisitor
{
  |Str:Obj?| onResult 
  
  new make(|Str:Obj?| onResult) 
  { 
    this.onResult = onResult
  }
  
  Str:Obj? result := [:]
  
  private MapValBuilder builder := MapValBuilder(result, this)
  
  override protected Void onMapEnd() { onResult(result) }
  
  override MapValVisitor key(Str key)
  {
    builder.key = key
    return builder
  }
}

class MapValBuilder : MapValVisitor
{
  new make(Str:Obj? result, MapBuilder parent) : super(parent) 
  {
    this.result = result
  }
  
  Str? key := null
  Str:Obj? result
  
  override protected Void onPrimitive(Obj? obj)
  {
    result[key] = obj
  }
  
  override MapVisitor onMapStart() { MapBuilder { result[key] = it } }
  override ListVisitor onListStart() { ListBuilder { result[key] = it } }
}

class ListBuilder : ListVisitor
{
  Obj?[] result := [,]
  |Obj?[]| onResult
  
  new make(|Obj?[]| onResult) { this.onResult = onResult }
  
  override protected Void onPrimitive(Obj? val)
  {
    result.add(val)
  }
  
  override protected Void onListEnd() { onResult(result) }
  override protected MapVisitor onMapStart() { MapBuilder { result.add(it) } }
  override protected ListVisitor onListStart() { ListBuilder { result.add(it) } }
}