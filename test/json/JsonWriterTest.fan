
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
    verifyJson("{}") { it.mapStart.mapEnd }
    verifyJson(
      Str<|{
             "foo": 1
           }|>) { 
     it.mapStart
          .mapKey("foo").num(1)
       .mapEnd }
  }
  
  Void testList()
  {
    verifyJson("[]") { it.listStart.listEnd }
    verifyJson(
      Str<|[
             1,
             2
           ]|>) { it.listStart.num(1).num(2).listEnd }
  }
  
  Void testWrongStates()
  {
    verifyStateErr("Not in map") { it.mapEnd }
    verifyStateErr("Not in map") { it.mapKey("aa") }
    verifyStateErr("Not in list") { it.listEnd }
    verifyStateErr("Not in list") { it.mapStart.listEnd }
    verifyStateErr("Not in map") { it.listStart.mapEnd }
  }
  Void verifyJson(Str expected, |JsonVisitor| builder)
  {
    buf := StrBuf()
    visitor := JsonWriter(buf.out)
    builder(visitor)
    echo(buf.toStr)
    verifyEq(expected, buf.toStr)
  }
  
  Void verifyStateErr(Str msg, |JsonVisitor| builder)
  {
    buf := StrBuf()
    visitor := JsonWriter(buf.out)
    try builder(visitor)
    catch (Err e)
    {
      verifyEq(e.msg, msg)
      return
    }
    fail("Expected Err($msg), but got json: $buf")
  }
}
