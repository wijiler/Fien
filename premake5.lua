workspace "FienCompiler"
configurations { "Debug", "Release", "Dist"}
architecture "x64"

include "Fien-Frontend"
include "Fien"

newaction {
    trigger     = "clean",
    description = "clean the software",
    execute     = function ()
       print("Cleaning")
       os.rmdir("./Binaries")
       os.remove("**.make")
       os.remove("Makefile")
       os.remove("**.vcxproj")
       os.remove("**.vcxproj.filters")
       os.remove("**.vcxproj.user")
       os.remove("**.sln")
       os.remove("./util/WijUtil/")
       os.remove("./Fien-Frontend/FienFrontend/")
       os.remove("./Fien/FienCompiler/")
       print("done.")
    end
}
