# Package

version     = "4.0.1"
author      = "HapticX"
description = "HappyX"
license     = "MIT"
backend     = "js"
srcDir      = "src"
binDir      = "out"
bin         = @["extension"]

# Deps

requires "nim >= 1.6.14"
requires "compiler >= 1.6.14"

import std/os

proc initialNpmInstall =
  if not dirExists "node_modules":
    exec "npm install"

# Tasks
task main, "This compiles the vscode Nim extension":
  exec "nim js --outdir:out --sourceMap src" / "extension.nim"

task release, "This compiles a release version":
  exec "nim js -d:release --opt:size --outdir:out -a:off -x:off -w:off --hints:off --panics:off --lineDir:off --sourceMap src" / "extension.nim"
