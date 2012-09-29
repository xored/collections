class JsonPrinter
{
  virtual Void writeJson(OutStream out, Obj? obj) 
  {
         if (obj == null) { out.writeChars("null") }
    else if (obj is Jsonable) writeJson(out, (obj->toJson()) )
    else if (obj is Json) writeJson(out, (obj as Json).val )
    else if (obj is Str)  writeJsonStr(out, obj)
    else if (obj is Num)  writeJsonNum(out, obj)
    else if (obj is Bool) writeJsonBool(out, obj)
    else if (obj is ConstMap)  writeJsonMap(out, obj)
    else if (obj is ConstList) writeJsonList(out, obj)
    else 
      writeJsonObj(out, obj)
  }

  Str? indent := "  "
  Str separator := ": "
  
  private Int level := 0

  private Void newline(OutStream out)
  {
    if(indent == null) return
    out.writeChar('\n')
    level.times { out.writeChars(indent) }
  }
  protected virtual Void writeJsonStr(OutStream out, Str str)
  {
    out.writeChar(JsonToken.quote)
    str.each |char|
    {
      if (char <= 0x7f)
      {
        switch (char)
        {
          case '\b': out.writeChar('\\').writeChar('b')
          case '\f': out.writeChar('\\').writeChar('f')
          case '\n': out.writeChar('\\').writeChar('n')
          case '\r': out.writeChar('\\').writeChar('r')
          case '\t': out.writeChar('\\').writeChar('t')
          case '\\': out.writeChar('\\').writeChar('\\')
          case '"':  out.writeChar('\\').writeChar('"')
          default: out.writeChar(char)
        }
      }
      else
      {
        out.writeChar('\\')
        out.writeChar('u')
        out.writeChars(char.toHex(4))
      }
    }
    out.writeChar(JsonToken.quote)
  }
 
  protected virtual Void writeJsonNum(OutStream out, Num num) { out.print(num) }
 
  protected virtual Void writeJsonBool(OutStream out, Bool bool) { out.print(bool) }

  protected virtual Void writeJsonMap(OutStream out, ConstMap map)
  {
    out.writeChar(JsonToken.objectStart)
    if(map.isEmpty)
    {
      out.writeChar(JsonToken.objectEnd)
      return
    }
    level++
    
    map.each |entry, i|
    {
      if (i != 0) out.writeChar(JsonToken.comma)
      newline(out)
      writeJsonPair(out, entry->key, entry->val)
    }
    
    level--
    newline(out)
    out.writeChar(JsonToken.objectEnd)
  }

  protected virtual Void writeJsonList(OutStream out, ConstList array)
  {
    out.writeChar(JsonToken.arrayStart)
    if(array.isEmpty) 
    {
      out.writeChar(JsonToken.arrayEnd)
      return
    }
    level++
    notPrimitives := false
    array.each |item,i|
    {
      if (i != 0) out.writeChar(JsonToken.comma)
      if((item isnot Str) && (item isnot Num) && (item isnot Bool))
      {
        newline(out)
        notPrimitives = true
      }
      writeJson(out, item)
    }
    level--
    if(notPrimitives)
      newline(out)
    out.writeChar(JsonToken.arrayEnd)
  }

  protected virtual Void writeJsonPair(OutStream out, Str key, Obj? val)
  {
    writeJsonStr(out, key)
    out.writeChars(separator)
    writeJson(out, val)
  }

  protected virtual Void writeJsonObj(OutStream out, Obj obj)
  {
    type := Type.of(obj)

    // if a simple, write it as a string
    ser := type.facet(Serializable#, false) as Serializable
    if (ser == null) throw IOErr("Object type not serializable: $type")

    if (ser.simple)
    {
      writeJsonStr(out, obj.toStr)
      return
    }

    // serialize as JSON object
    out.writeChar(JsonToken.objectStart)
    type.fields.each |f, i|
    {
      if (i != 0) out.writeChar(JsonToken.comma).writeChar('\n')
      if (f.isStatic || f.hasFacet(Transient#) == true) return
      writeJsonPair(out, f.name, f.get(obj))
    }
    out.writeChar(JsonToken.objectEnd)
  }

}
