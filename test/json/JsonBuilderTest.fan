
class JsonBuilderTest : Test
{
  Void testBuildPrimitives()
  {
    verifyBuild(null) { it.nil }
    verifyBuild(12.5d) { it.num(12.5d) }
    verifyBuild("foo") { it.str("foo") }
    verifyBuild(true) { it.bool(true) }
  }
  
  Void testBuildList()
  {
    verifyBuild(Obj?[,]) { it.list {} }
    verifyBuild(Obj?[1,2,3]) { it.list |l| { l.num(1).num(2).num(3) } }
    verifyBuild(Obj?[1, "a", null, true, false]) { 
      it.list|l|
      {
        l.num(1).str("a").nil.bool(true).bool(false)
      }
    }
  }
  
  Void testBuildMap()
  {
    verifyBuild([Str:Obj?][:]) { it.map {} }
    verifyBuild(["a":1, "b":"str","c":null, "d":true, "e":false]) { 
      it.map |m|
      {
        m.key("a").num(1)
        .key("b").str("str")
        .key("c").nil
        .key("d").bool(true)
        .key("e").bool(false)
      }
    }
  }
  
  Void testComposite()
  {
    verifyBuild(
      [Str:Obj?][
          "version" : "2.0",
          "id" : 433,
          "err" : [Str:Obj?][
              "code" : -32700,
              "msg" : "Invalid params",
              "data" : Obj?[14, "bool", false]
            ]
        ]) {  
          it.map |m| {
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
  }
  
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
  
  Void verifyBuild(Obj? expected, |JsonVisitor| f)
  {
    builder := JsonBuilder()
    f(builder)
    verifyEq(expected, builder.done.result)
  }
}

class MyResult : VisitResult 
{
  new make(Int result) { this.result = result }
  Int result 
}
class IdFinder : JsonVisitor
{
  override protected MapVisitor? onMapStart()
  {
    IdFindingMap { done.result = it }
  }
  
  override MyResult done := MyResult(-1)
}

class IdFindingMap : MapVisitor 
{
  |Int| onResult
  new make(|Int| onResult) { this.onResult = onResult }
  
  override MapValVisitor key(Str val)
  {
    val == "id" ?  FindingValVisitor(this) : super.key(val)
  }
}

class FindingValVisitor : MapValVisitor
{
  new make(IdFindingMap parent):super(parent) {}
  
  override Void onPrimitive(Obj? val)
  {
    if(val is Int) ((IdFindingMap)parent).onResult(val)
  }
}