using build
class Build : build::BuildPod
{
  new make()
  {
    podName = "collections"
    summary = ""
    srcDirs = [`test/`, `fan/`, `fan/treemap/`]
    depends = ["sys 1.0"]
  }
}
