# Package

version     = "3.2.1"
author      = "HapticX"
description = "HappyX"
license     = "MIT"
backend     = "js"
srcDir      = "src"
binDir      = "out"
bin         = @["extension"]

# Deps

requires "nim >= 1.6.10"
requires "compiler >= 1.6.10"

import std/os

proc initialNpmInstall =
  if not dirExists "node_modules":
    exec "npm install"

# Tasks
task main, "This compiles the vscode Nim extension":
  exec "nim js --outdir:out --checks:on --sourceMap src"/"extension.nim"

task release, "This compiles a release version":
  exec "nim js -d:release -d:danger --opt:size --outdir:out --checks:off --sourceMap src"/"extension.nim"
