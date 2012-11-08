
class ConstJsonBuilderTest : EquivTest
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
    verifyBuild(ConstList.empty) { it.list {} }
    verifyBuild(ConstList.fromList([1,2,3])) { it.list |l| { l.num(1).num(2).num(3) } }
    verifyBuild(ConstList.fromList([1, "a", null, true, false])) { 
      it.list|l|
      {
        l.num(1).str("a").nil.bool(true).bool(false)
      }
    }
  }
  
  Void testBuildMap()
  {
    verifyBuild(ConstMap.emptyHashMap) { it.map {} }
    verifyBuild(ConstMap.hashMap(["a":1, "b":"str","c":null, "d":true, "e":false])) { 
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
      ConstMap.hashMap([
          "version" : "2.0",
          "id" : 433,
          "err" : ConstMap.hashMap([
              "code" : -32700,
              "msg" : "Invalid params",
              "data" : ConstList.fromList([14, "bool", false])
            ])
        ])) {  
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
     verifyBuild(ConstMap.hashMap(["foo":32, "bar":ConstList.fromList([3,"s",true])])) |json| { 
     json.map |m| {
      m.key("foo").num(32)
      m.key("bar").list |l| 
      { 
        l.num(3).str("s").bool(true) 
      }
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
    builder := ConstJsonBuilder()
    f(builder)
    verifyEquiv(expected, builder.done.result)
  }
}
