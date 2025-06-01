project "FienFrontend"
    language "C++"
    targetname "FienFrontend"
    location "FienFrontend"
    kind "StaticLib"
    outputdir = "%{cfg.system}-%{cfg.architecture}/%{cfg.buildcfg}"

    cppdialect "C++20"

    targetdir("%{wks.location}/Binaries/" .. outputdir .. "/%{prj.name}")
    objdir("%{wks.location}/Binaries/Intermediates/" .. outputdir .. "/%{prj.name}")
    files { "include/**.hpp", "src/**.cpp" }
    includedirs { "./include/"}
    filter "configurations:Debug"
        defines { "DEBUG" }
        symbols "On"

    filter "configurations:Release"
        optimize "On"
        symbols "On"

    filter "configurations:Dist"
        optimize "On"

    filter "system:windows"
        systemversion "latest"

    filter "action:gmake"
    prebuildcommands {

        "mkdir -p" .. " %[%{wks.location}/Binaries/]",
        "mkdir -p" .. " %[%{wks.location}/Binaries/Intermediates/]",

        "mkdir -p" .. " %[%{wks.location}/Binaries/" .. outputdir .. "]",
        "mkdir -p" .. " %[%{wks.location}/Binaries/Intermediates/" .. outputdir .. "]",
    }

    filter "not action:gmake"
        prebuildcommands {

            "{MKDIR}" .. " %[%{wks.location}/Binaries/]",
            "{MKDIR}" .. " %[%{wks.location}/Binaries/Intermediates/]",

            "{MKDIR} %[%{wks.location}/Binaries/" .. outputdir .. "]",
            "{MKDIR} %[%{wks.location}/Binaries/Intermediates/" .. outputdir .. "]",
        }

    filter "action:gmake"
    toolset "clang"
    buildoptions {"-Wextra", "-Wall", "-mavx", "-mavx2"}

    filter "not action:gmake"
    toolset "msc"
    filter""