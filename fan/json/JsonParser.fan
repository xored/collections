class JsonParser
{
  new make(InStream in, Bool checked := true)
  {
    this.in = in
  }
  
  InStream in
  
  private Int pos := 0
  internal Int cur := '?'
  Void parse(JsonVisitor visitor)
  {
    pos = 0
    consume
    skipWhitespace
    if(cur == JsonToken.quote) visitor.str(parseStr)
    else if(cur.isDigit || this.cur == '-') visitor.num(parseNum)
    else if(cur == 't')
    {
      "true".each { consume(it) }
      visitor.bool(true)
    }
    else if(cur == 'f')
    {
      "false".each { consume(it) }
      visitor.bool(false)
    }
    else if(cur == 'n')
    {
      "null".each { consume(it) }
      visitor.nil
    }
    else if(cur == JsonConsts.arrayStart)
    {
      p := ListParser(this)
      visitor.list(p.func)
      p.complete
    }
    else if (cur == JsonConsts.objectStart)
    {
      p := MapParser(this)
      visitor.map(p.func)
      p.complete
    }
    else throw err("Unexpected token " + this.cur)
  }
  
  internal Void consume(Int expected := -1)
  {
    if(cur == -1) throw ParseErr("Unexpected <eof>")
    if(expected != -1 && cur != expected) 
    {
      str := cur == -1 ? "<eof>" : cur.toChar
      throw err("Expected ${expected.toChar}, got $str")
    }
    this.cur = in.readChar ?: -1 
    pos++
    
  }
  
  internal Void skipWhitespace()
  {
    while(this.cur.isSpace)
      consume
  }
  
  private StrBuf integral := StrBuf()
  private StrBuf fractional := StrBuf()
  private StrBuf exponent := StrBuf()
  
  internal Num parseNum()
  {
    integral.clear
    fractional.clear
    exponent.clear
    if (maybe('-'))
      integral.add("-")

    while (this.cur.isDigit)
    {
      integral.addChar(this.cur)
      consume
    }

    if (this.cur == '.')
    {
      decimal := true
      consume
      while (this.cur.isDigit)
      {
        fractional.addChar(this.cur)
        consume
      }
    }

    if (this.cur == 'e' || this.cur == 'E')
    {
      exponent.addChar(this.cur)
      consume
      if (this.cur == '+') consume
      else if (this.cur == '-')
      {
        exponent.addChar(this.cur)
        consume
      }
      while (this.cur.isDigit)
      {
        exponent.addChar(this.cur)
        consume
      }
    }

    Num? num := null
    if (fractional.size > 0)
      num = Float.fromStr(integral.toStr+"."+fractional.toStr+exponent.toStr)
    else if (exponent.size > 0)
      num = Float.fromStr(integral.toStr+exponent.toStr)
    else num = Int.fromStr(integral.toStr)

    return num
  }
  
  private StrBuf str := StrBuf()
  internal Str parseStr()
  {
    str.clear
    consume(JsonToken.quote) //open quote
    while( cur != JsonToken.quote )
    {
      if(cur == -1) throw ParseErr("Unexpected <eof> inside str literal")
      if (cur == '\\')
      {
        str.addChar(escape)
      }
      else
      {
        str.addChar(cur)
        consume
      }
    }
    consume(JsonToken.quote)
    return str.toStr
  }
  
  private Bool maybe(Int tt)
  {
    if (this.cur != tt) return false
    consume
    return true
  }

  private Int escape()
  {
    // consume slash
    consume //slash

    // check basics
    switch (cur)
    {
      case 'b':   consume; return '\b'
      case 'f':   consume; return '\f'
      case 'n':   consume; return '\n'
      case 'r':   consume; return '\r'
      case 't':   consume; return '\t'
      case '"':   consume; return '"'
      case '\\':  consume; return '\\'
      case '/':   consume; return '/'
    }

    // check for uxxxx
    if (cur == 'u')
    {
      consume
      n3 := cur.fromDigit(16); consume
      n2 := cur.fromDigit(16); consume
      n1 := cur.fromDigit(16); consume
      n0 := cur.fromDigit(16); consume
      if (n3 == null || n2 == null || n1 == null || n0 == null) throw err("Invalid hex value for \\uxxxx")
      return n3.shiftl(12).or(n2.shiftl(8)).or(n1.shiftl(4)).or(n0)
    }

    throw err("Invalid escape sequence")
  }
  
  internal Err err(Str msg) { ParseErr("$msg at $pos") }
}

internal abstract class SubParser
{
  protected JsonParser parser
  new make(JsonParser parser)
  {
    this.parser = parser
  }
  
  private Bool parsed := false
  virtual Func func() { |Obj visitor| 
    { 
      if(parsed) return
      parse(visitor) 
      parsed = true
    } }
  
  public Void complete()
  {
    if(parsed) return
    parse(null)
  }
  
  abstract Void parse(Obj? visitor)
  
}

internal class ListParser : SubParser
{
  new make(JsonParser parser) : super(parser) {}
  
  override Void parse(Obj? v)
  {
    ListVisitor? visitor := v as ListVisitor
    parser.consume(JsonConsts.arrayStart)
    parser.skipWhitespace
    isFirst := true
    while(parser.cur != JsonConsts.arrayEnd)
    {
      if(!isFirst)
      {
        parser.consume(JsonConsts.comma)
        parser.skipWhitespace
      }
      isFirst = false
      if(parser.cur == JsonConsts.quote) 
        visitor = visitor?.str(parser.parseStr)
      else if(parser.cur.isDigit || parser.cur == '-') 
        visitor = visitor?.num(parser.parseNum)
      else if(parser.cur == 't')
      {
        "true".each { parser.consume(it) }
        visitor = visitor?.bool(true)
      }
      else if(parser.cur == 'f')
      {
        "false".each { parser.consume(it) }
        visitor = visitor?.bool(false)
      }
      else if(parser.cur == 'n')
      {
        "null".each { parser.consume(it) }
        visitor = visitor?.nil
      }
      else if(parser.cur == JsonConsts.arrayStart)
      {
        p := ListParser(parser)
        visitor = visitor?.list(p.func)
        p.complete
      }
      else if (parser.cur == JsonConsts.objectStart)
      {
        p := MapParser(parser)
        visitor = visitor?.map(p.func)
        p.complete
      }
      else throw parser.err("Unexpected token " + parser.cur)
      
      parser.skipWhitespace
    }
    parser.consume(JsonConsts.arrayEnd)
  }
}

internal class MapParser : SubParser
{
  new make(JsonParser parser) : super(parser) 
  {
    valParser = MapValParser(parser)
  }
  
  private MapValParser valParser
  override Void parse(Obj? v)
  {
    visitor := v as MapVisitor
    parser.consume(JsonConsts.objectStart)
    parser.skipWhitespace
    isFirst := true
    while(parser.cur != JsonConsts.objectEnd)
    {
      if(!isFirst)
      {
        parser.consume(JsonConsts.comma)
        parser.skipWhitespace
      }
      isFirst = false
      key := parser.parseStr
      valVisitor := visitor?.key(key)
      parser.skipWhitespace
      parser.consume(JsonConsts.colon)
      parser.skipWhitespace
      valParser.parse(valVisitor)
      visitor = valParser.resVisitor
      parser.skipWhitespace
    }
    parser.consume(JsonConsts.objectEnd)
  }
}

internal class MapValParser : SubParser
{
  new make(JsonParser parser) : super(parser) {}
  
  override Void parse(Obj? v)
  {
    visitor := v as MapValVisitor
    if(parser.cur == JsonConsts.quote) 
      resVisitor = visitor?.str(parser.parseStr)
    else if(parser.cur.isDigit || parser.cur == '-') 
      resVisitor = visitor?.num(parser.parseNum)
    else if(parser.cur == 't')
    {
      "true".each { parser.consume(it) }
      resVisitor = visitor?.bool(true)
    }
    else if(parser.cur == 'f')
    {
      "false".each { parser.consume(it) }
       resVisitor = visitor?.bool(false)
    }
    else if(parser.cur == 'n')
    {
      "null".each { parser.consume(it) }
      resVisitor = visitor?.nil
    }
    else if(parser.cur == JsonConsts.arrayStart)
    {
      p := ListParser(parser)
      resVisitor = visitor?.list(p.func)
      p.complete
    }
    else if (parser.cur == JsonConsts.objectStart)
    {
      p := MapParser(parser)
      resVisitor = visitor?.map(p.func)
      p.complete
    }
    else throw parser.err("Unexpected token " + parser.cur)
  }
  
  MapVisitor? resVisitor
}
