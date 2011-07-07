using build
class Build : build::BuildPod
{
  new make()
  {
    podName = "collections"
    summary = ""
    srcDirs = [`test/`, `fan/`, `fan/treemap/`, `fan/sets/`, `fan/lists/`, `fan/hashMap/`]
    depends = ["sys 1.0", "constArray 1.0"]
  }
}
