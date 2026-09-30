require "premake-ps5"

newaction {
    trigger = "clean",
    description = "Remove generated workspace files",
    execute = function()
        os.execute('cmd /c "if exist workspaces rmdir /s /q workspaces"')
    end
}

workspace "CourseDevProject"
    location "workspaces"
    configurations { "Debug", "Release" }
    platforms { "x64", "Prospero" }
    startproject "CourseDevProject"

project "CourseDevProject"
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++14"
    files { "src/**.cpp", "src/**.h", "src/**.hpp" }
    targetdir ("build/%{cfg.platform}/bin/%{cfg.buildcfg}")
    warnings "Extra"
    flags { "FatalWarnings" }

filter "configurations:Debug"
    symbols "On"
    optimize "Off"
    defines { "DEBUG" }

filter "configurations:Release"
    symbols "Off"
    optimize "Full"
    defines { "NDEBUG" }

filter "platforms:x64"
    system "windows"
    architecture "x86_64"
    defines { "PLATFORM_WINDOWS" }

filter "platforms:Prospero"
    system "prospero"
    defines { "PLATFORM_PROSPERO" }

filter {}
