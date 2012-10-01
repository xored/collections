class JsonParser
{
  new make(InStream in)
  {
    this.in = in
  }
  
  InStream in
  
  private Int pos := 0
  private Int cur := '?'
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
  
  private Void consume(Int expected := -1)
  {
    if(expected != -1 && cur != expected) 
      throw err("Expected ${expected.toChar}, got ${cur.toChar}")
    this.cur = in.readChar ?: -1 
    pos++
    
  }
  
  private Void skipWhitespace()
  {
    while(this.cur.isSpace)
      consume
  }
  
  private StrBuf integral := StrBuf()
  private StrBuf fractional := StrBuf()
  private StrBuf exponent := StrBuf()
  
  private Num parseNum()
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
  private Str parseStr()
  {
    str.clear
    consume(JsonToken.quote) //open quote
    while( cur != JsonToken.quote )
    {
      if(cur == -1) throw IOErr("Unexpected eof inside str literal")
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
  
  private Err err(Str msg) { ParseErr("$msg at $pos") }
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
  
  override Void parse(Obj? visitor)
  {
    ListVisitor? lv := visitor as ListVisitor
  }
}

internal class MapParser : SubParser
{
  new make(JsonParser parser) : super(parser) {}
  
  override Void parse(Obj? visitor)
  {
    MapVisitor? lv := visitor as MapVisitor
  }
}
