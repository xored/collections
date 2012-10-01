
class JsonWriterTest : Test
{
  Void testPrimitive()
  {
    verifyJson("null") { it.nil }
    verifyJson("\"null\"") { it.str("null") }
    verifyJson("42") { it.num(42) }
    verifyJson("12.5") { it.num(12.5d) }
    verifyJson("12.5") { it.num(12.5f) }
  }
  
  Void testMap()
  {
    verifyJson("{}") { it.map {} }
    verifyJson(
      Str<|{
             "foo": 1
           }|>) { 
     it.map { it.key("foo").num(1) }
    }
  }
  
  Void testList()
  {
    verifyJson("[]") { it.list {} }
    verifyJson(
      Str<|[
             1,
             2
           ]|>) { it.list{ it.num(1).num(2) } }
  }
  
  Void testVisit()
  {
    verifyJson("[]") { it.visit([,]) }
    verifyJson("{}") { it.visit([:]) }
    verifyJson("null") { it.visit(null) }
    verifyJson("\"null\"") { it.visit("null") }
    verifyJson("52") { it.visit(52) }
    verifyJson("5.5") { it.visit(5.5d) }
    verifyJson("5.5") { it.visit(5.5f) }
    verifyJson(Str<|[
                      1,
                      2,
                      3
                    ]|>) { it.visit([1,2,3]) }
  }
  
  Void testComposite()
  {
    verifyJson(
      Str<|{
             "version": "2.0",
             "id": 433,
             "err": {
               "code": -32700,
               "msg": "Invalid params",
               "data": [
                 14,
                 "bool",
                 false
               ]
             }
           }|>) {  
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
  Void verifyJson(Str expected, |JsonVisitor| f)
  {
    buf := StrBuf()
    visitor := JsonWriter(buf.out)
    f(visitor)
    verifyEq(expected, buf.toStr)
  }
}
