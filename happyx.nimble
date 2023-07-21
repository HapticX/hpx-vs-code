# Package

version     = "3.9.7"
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
  exec "nim js --outdir:out --sourceMap src" / "extension.nim"

task release, "This compiles a release version":
  exec "nim js -d:release --opt:size --outdir:out -a:off -x:off -w:off --hints:off --sourceMap src" / "extension.nim"
