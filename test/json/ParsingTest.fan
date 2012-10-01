class ParsingTest : Test
{
  Void testParsing()
  {
    json := ConstJson.fromStream("{\"foo\":\"bar\"}".in)
    verifyEq(json->foo, "bar")
  }

  Void testIncompleteParsing()
  {
//    verifyErr(ParseErr#) { ConstJson.fromStr("{\"") }
//    verifyErr(ParseErr#) { ConstJson.fromStr("{\"foo") }
//    verifyErr(ParseErr#) { ConstJson.fromStr("{\"foo\"") }
//    verifyErr(ParseErr#) { ConstJson.fromStr("{\"foo\":") }
//    verifyErr(ParseErr#) { ConstJson.fromStr("{\"foo\":\"bar") }
//    verifyErr(ParseErr#) { ConstJson.fromStr("{\"foo\":\"bar\"") }
//    
//    verifyErr(ParseErr#) { ConstJson.fromStr("[\"foo") }
//    verifyErr(ParseErr#) { ConstJson.fromStr("[\"foo\"") }
//    verifyErr(ParseErr#) { ConstJson.fromStr("[\"foo\",") }
//    verifyErr(ParseErr#) { ConstJson.fromStr("[\"foo\", \"bar") }
//    verifyErr(ParseErr#) { ConstJson.fromStr("[\"foo\", \"bar\"") }
  }
}
