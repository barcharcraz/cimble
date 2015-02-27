import strutils
import os
const defaultPath = "%APPDATA%\cimble"
## Enum for generators, the stringify operator
## Will output the name of the generator that can
## be passed to cmake's -G option, not all generators
## will work on all platforms
type CmakeGenerator* = enum
  cgVisualStudio6 = "Visual Studio 6",
  cgVisualStudio7 = "Visual Studio 7",
  cgVisualStudio12 = "Visual Studio 12 2013",
  cgVisualStudio12x64 = "Visual Studio 12 2013 Win64",
  cgNMake = "NMake Makefiles",
  cgMSYSMake = "MSYS Makefiles",
  cgMinGWMake = "MingGW Makefiles",
  cgUnixMake = "Unix Makefiles"

## specifies a build type, in particular on windows
## where there are many ways that one might want to build
type RuntimeLinkage* = enum
  rtlDynamic = "/MD", ## multithreaded dynamic runtime
  rtlDynamicDebug = "/MDd", ## Multithreaded dynamic runtime
  rtlStatic = "/MT", ## Multithreaded static runtime
  rtlStaticDebug = "/MTd" ## multithreaded Static debug runtime



type OutputType* = enum
  otStatic,
  otDynamic,
  otBoth ## for when you can change the output type after
         ## cmake runs

## specifies an option for things like rtl linkage
## or static vs dynamic builds, we need this because
## some libs may use something like LIB_USE_DYNAMIC
## and some may use something like LIB_USE_STATIC,
## when specifing options we need to have a consistant
## way to do this
type CmakeOption* = object
  name*: string
  on*: string
  off*: string

type CmakeBuildInfo* = object
  libraryName*: string
  generator*: CmakeGenerator
  defaultRtl*: OutputType
  defaultOutput*: OutputType
  rtlStatic*: CmakeOption
  outputStatic*: CmakeOption
  dynamicTarget*: string ## target to build to get a dynamic library
  staticTarget*: string  ## target to build to get a static library

type CmakeBuildOptions* = object
  rtlLinkage*: OutputType
  output*: OutputType


proc changeRtlLinkage(cflags: string, newrtl: RuntimeLinkage): string =
  ## changes the rtl linkage by modifying the cflags option,
  ## this is used for libraies that do not provide options to change
  ## rtl linkage, cflags is the initial value of the cflags option,
  ## the proc returns the new value
  var flags = split(cflags)
  flags.map do(x: var string):
    for elm in RuntimeLinkage:
      if x == $elm: x = $newrtl
  result = flags.join(" ")

proc buildPath(libname: string): string =
  result = defaultPath / "build" / libname
proc sourcePath(libname: string): string =
  result = defaultPath / "source" / libname
proc genCmakeCmd(info: CmakeBuildInfo, options: CmakeBuildOptions): string =
  result = ""
  result &= info.libraryName.sourcePath
  result &= " --build " & info.libraryName.buildPath
  result &= " -G\"" & $info.generator & "\""
  if info.defaultRtl != options.rtlLinkage:
    if info.rtlStatic.name != "":
      result &= " -D" & info.rtlStatic.name & ":BOOL"
      if options.rtlLinkage == otStatic:
        result &= info.rtlStatic.on
      else:
        result &= info.rtlStatic.off
    else: assert(false) # TODO: do all the C flags replacement stuff
  if info.defaultOutput != otBoth:
    if info.outputStatic.name != "":
      result &= " -D" & info.outputStatic.name & ":BOOL"
      if options.output == otStatic:
        result &= info.outputStatic.on
      else:
        result &= info.outputStatic.off
proc runCmake*(info: CmakeBuildInfo, options: CmakeBuildOptions) {.compileTime.} =
  var cmd = "cmake " & genCmakeCmd(info, options)
  echo gorge(cmd)
proc compile*(info: CmakeBuildInfo, options: CmakeBuildOptions) {.compileTime.} =
  case info.generator
  of cgVisualStudio12x64:
    echo gorge("""%VS120COMMONTOOLS%\..\..\VC\vcvarsall.bat amd64""")
    var buildcmd = "devenv " & info.libraryName.buildPath / info.libraryName & ".sln" & " /build Debug "
    buildcmd &= "/project INSTALL.vcxproj"
    echo gorge(buildcmd)
  else:
    echo "error: not a covered generator type"

