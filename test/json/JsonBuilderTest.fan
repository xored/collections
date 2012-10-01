
class JsonBuilderTest
{
  Void test1()
  {
    json := JsonBuilder()
    json.map |m| {
      m.key("foo").num(32)
      m.key("bar").list |l| 
      { 
        l.num(3).str("s").bool(true) 
      }
    }
  }
  
  Void buildResponse()
  {
    JsonBuilder().list |l|
    {
      l.num(1).str("").bool(true).map |m|
      {
        m.key("dsa").num(43).key("cdsa")
      }
    }
//    
//    JsonBuilder().map |m| 
//    {
//      m.key("version").str("2.0")
//      .key("id").num(433)
//      .key("err").map |e| 
//      {
//        e.key("code").num(-32700)
//        .key("msg").str("Invalid params")
//        .key("data").list |l| 
//        {
//          l.num(14).str("bool").bool(false)
//        }
//      }
//    }
  }
}
