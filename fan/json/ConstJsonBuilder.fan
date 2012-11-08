
class ConstJsonBuilder : JsonVisitor
{
  protected BuildResult result := BuildResult(null)
  
  override protected Void onPrimitive(Obj? val) { result.result = val }
  
  override protected MapVisitor? onMapStart() { ConstMapBuilder { result.result = it } }
  
  override protected ListVisitor? onListStart() { ConstListBuilder { result.result = it } }
  
  override BuildResult done() { result }
}


class ConstMapBuilder : MapVisitor
{
  |ConstMap| onResult 
  
  new make(|ConstMap| onResult) 
  { 
    this.onResult = onResult
  }
  
  ConstMap result := ConstHashMap.empty
  
  private ConstMapValBuilder builder := ConstMapValBuilder(this)
  
  override protected Void onMapEnd() 
  {
    updatePair
    onResult(result) 
  }
  
  override MapValVisitor key(Str key)
  {
    updatePair
    builder.key = key
    return builder
  }
  private Bool firstPair := true
  private Void updatePair() {
    if(firstPair) {
      firstPair = false;
      return
    }
    result = result.set(builder.key, builder.result)
  }
}

class ConstMapValBuilder : MapValVisitor
{
  new make(ConstMapBuilder parent) : super(parent) 
  {
  }
  
  Str? key := null
  Obj? result := null
  
  override protected Void onPrimitive(Obj? obj)
  {
    result = obj
  }
  
  override MapVisitor? onMapStart() { ConstMapBuilder { result = it } }
  override ListVisitor? onListStart() { ConstListBuilder { result = it } }
}

class ConstListBuilder : ListVisitor
{
  ConstList result := ConstList.empty
  |ConstList| onResult
  
  new make(|ConstList| onResult) { this.onResult = onResult }
  
  override protected Void onPrimitive(Obj? val)
  {
    result = result.add(val)
  }
  
  override protected Void onListEnd() { onResult(result) }
  override protected MapVisitor? onMapStart() { ConstMapBuilder { result = result.add(it) } }
  override protected ListVisitor? onListStart() { ConstListBuilder { result = result.add(it) } }
}