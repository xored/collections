
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
  }
  
  Void verifyParse(Str input, Str? expected := null)
  {
    expected = expected ?: input
    out := StrBuf()
    visitor := JsonWriter(out.out)
    JsonParser(input.in).parse(visitor)
    verifyEq(out.toStr, expected)
  }
}
