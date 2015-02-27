import cimble
const buildinfo: CmakeBuildInfo = CmakeBuildInfo(
    libraryName: "glfw",
    generator: cgVisualStudio12x64,
    defaultRtl: otDynamic,
    defaultOutput: otStatic,
    rtlStatic: CmakeOption(name: "USE_MSVC_RUNTIME_LIBRARY_DLL", on: "NO", off: "YES"),
    outputStatic: CmakeOption(name: "BUILD_SHARED_LIBS", on: "NO", off: "YES"),
    staticTarget: "",
    dynamicTarget: ""
)

#static:
#    var buildOpts = CmakeBuildOptions(rtlLinkage: otStatic, output: otStatic)
#    runCmake(buildinfo, buildOpts)
