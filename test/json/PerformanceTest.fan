using util

class PerformanceTest : Test {
  Void test1() {
    for(i:=0; i<10; i++) {
      measure("util", |->|{normal})
      measure("streaming", |->|{streaming})
      measure("constStreaming", |->|{constStreaming})
      echo("")
    }
  }

  private Void measure(Str name, |->| f) {
    t1 := Duration.nowTicks
    f()
    t2 := Duration.nowTicks
    echo("${name}: ${(t2-t1)/1000000}ms")
  }

  private Void normal() {
    for (i:=0;i<100;i++) {
      in := file.in
      result := JsonInStream(in).readJson
    }
  }

  private Void streaming() {
    for (i:=0;i<100;i++) {
      in := file.in
      JsonBuilder jb := JsonBuilder()
      JsonParser(in).parse(jb)
      result := (jb.done as BuildResult).result
    }
  }
  
  private Void constStreaming() {
    for (i:=0;i<100;i++) {
      in := file.in
      JsonVisitor jb := ConstJsonBuilder()
      JsonParser(in).parse(jb)
      result := (jb.done as BuildResult).result
      a := 1
    }
  }
  
  
  private File file := PerformanceTest#.pod.file(`/res/sample.json`) 

}
