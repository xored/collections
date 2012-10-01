
class JsonParserTest : Test
{
  Void test1()
  {
    verifyParse("".toCode)
    verifyParse("foo".toCode)
    verifyParse("\u0433".toCode)
    verifyParse("42")
    verifyParse("-34")
    verifyParse("1.43e12", "1.43E12")
    verifyParse("true", "true")
    verifyParse("false", "false")
    verifyParse("null", "null")
    verifyParse("{}", "{}")
    verifyParse("[]", "[]")
    verifyParse("[1 ,2, 3]", Str<|[
                                    1,
                                    2,
                                    3
                                  ]|>)
    
    verifyParse("[1 ,2, 3, true, null, false, \"whatever\"]", 
                             Str<|[
                                    1,
                                    2,
                                    3,
                                    true,
                                    null,
                                    false,
                                    "whatever"
                                  ]|>)
     verifyParse("{ \"foo\":42 }", 
                             Str<|{
                                    "foo": 42
                                  }|>)
    
    verifyParse(  Str<|{
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
                       }|>,
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
           }|>)
  }
  
  Void testNegative()
  {
    [
      "\"",
      "{",
      "[",
      "{\"",
      "[\"",
      "{\"a\"",
      "{\"a\":",
      "{\"a\":\"b",
      "{\"a\":\"b\"",
      "[\"foo",
      "[\"foo\"",
      "[\"foo\",",
      "[\"foo\", \"bar",
      "[\"foo\", \"bar\""
    ].each { verifyParseErr(it) }
  }
  
  Void verifyParseErr(Str input, Type errType := ParseErr#) 
  {
    verifyErr(errType) { JsonParser(input.in).parse(JsonVisitor()) }
  }
  
  Void verifyParse(Str input, Str? expected := null)
  {
    expected = expected ?: input
    out := StrBuf()
    visitor := JsonWriter(out.out)
    JsonParser(input.in).parse(visitor)
    echo(out.toStr)
    verifyEq(out.toStr, expected)
  }
}
