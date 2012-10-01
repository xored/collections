
class JsonBuilderTest : Test
{
  Void test1()
  {
    json := JsonVisitor()
    json.map |m| {
      m.key("foo").num(32)
      m.key("bar").list |l| 
      { 
        l.num(3).str("s").bool(true) 
      }
    }
  }
  
  Void test2()
  {
    JsonVisitor().map |m| 
    {
      m.key("version").str("2.0")
      .key("id").num(433)
      .key("err").map |e| 
      {
        e.key("code").num(-32700)
        .key("msg").str("Invalid params")
        .key("data").list |l| 
        {
          l.num(14).str("bool").bool(false)
        }
      }
    }
  }
  
  Void testSearchValue()
  {
    result := IdFinder().map |m| 
    {
      m.key("version").str("2.0")
      .key("id").num(433)
      .key("err").map |e| 
      {
        e.key("code").num(-32700)
        .key("msg").str("Invalid params")
        .key("data").list |l| 
        {
          l.num(14).str("bool").bool(false)
        }
      }
    }
    
    verifyEq(result->result, 433)
  }
}

class MyResult : VisitResult 
{
  new make(Int result) { this.result = result }
  Int result 
}
class IdFinder : JsonVisitor
{
  override MyResult map(|MapVisitor| f)
  {
    v := IdFindingMap()
    f(v)
    return MyResult(v.result)
  }
}

class IdFindingMap : MapVisitor 
{
  Int result := -1
  override MapValVisitor key(Str val)
  {
    val == "id" ?  FindingValVisitor(this) : super.key(val)
  }
}

class FindingValVisitor : MapValVisitor
{
  new make(IdFindingMap parent):super(parent) {}
  override MapVisitor num(Num val)
  {
    if(val is Int) parent->result = val
    return super.num(val)
  }
}