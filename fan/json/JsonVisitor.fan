
class JsonVisitor
{
  new make(JsonVisitor? v := null) { this.v = v }
  JsonVisitor? v
  // Primitives
  virtual JsonVisitor nil() { v?.nil ?: this }
  virtual JsonVisitor bool(Bool val) { v?.bool(val) ?: this }
  virtual JsonVisitor num(Num val) { v?.num(val) ?: this }
  virtual JsonVisitor str(Str val) { v?.str(val) ?: this }
  
  // Containers
  virtual JsonVisitor mapStart() { v?.mapStart ?: this}
  virtual JsonVisitor mapKey(Str key) { v?.mapKey(key) ?: this}
  virtual JsonVisitor mapEnd() { v?.mapEnd ?: this}
  virtual JsonVisitor listStart() { v?.listStart ?: this }
  virtual JsonVisitor listEnd() { v?.listEnd ?: this }
  
  //Err handling
  virtual JsonVisitor err(Err e) { v?.err(e) ?: this }
}
