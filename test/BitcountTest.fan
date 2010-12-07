
class BitcountTest : Test
{
  Void test1()
  {
    1000.times 
    { 
      64.times 
      { 
        verifyEq(it, BitmapNode.bitCount(randInt(it)))
      }
    }
  }

  **
  ** Returns random integer
  ** 
  private Int randInt(Int bitCount)
  {
    Str.fromChars(['0'].addAll(shuffle([,].fill('1', bitCount).fill('0', 63-bitCount)))).toInt(2)
  }
  
  private Obj?[] shuffle(Obj?[] list)
  {
    result := Obj?[,]
    list.size.times { result.add(list.remove(list.random)) }
    return result
  }
}
