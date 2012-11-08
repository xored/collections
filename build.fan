using build
class Build : build::BuildPod
{
  new make()
  {
    podName = "collections"
    summary = ""
    srcDirs = [`test/`, `test/json/`, `fan/`, `fan/treemap/`, `fan/sets/`, `fan/lists/`, `fan/json/`, `fan/hashMap/`]
    depends = ["sys 1.0", "util 1.0"]
    resDirs = [`res/`]
  }
}
