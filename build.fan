using build
class Build : build::BuildPod
{
  new make()
  {
    podName = "collections"
    summary = ""
    srcDirs = [`test/`, `fan/`]
    depends = ["sys 1.0"]
  }
}
