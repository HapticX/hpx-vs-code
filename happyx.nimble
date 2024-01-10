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
  exec "nim js --outdir:out --checks:on --sourceMap src/nimvscode.nim"

task release, "This compiles a release version":
  exec "nim js -d:release -d:danger --outdir:out --checks:off --sourceMap src/nimvscode.nim"

task vsix, "Build VSIX package":
  initialNpmInstall()  
  var cmd = "npm exec -c 'vsce package --out out/nimvscode-" & version & ".vsix'"
  when defined(windows):
    cmd = "powershell.exe " & cmd
  exec cmd

task install_vsix, "Install the VSIX package":
  initialNpmInstall()
  exec "code --install-extension out/nimvscode-" & version & ".vsix"

# Tasks for maintenance
task audit_node_deps, "Audit Node.js dependencies":
  initialNpmInstall()
  exec "npm audit"
  echo "NOTE: 'engines' versions in 'package.json' need manually audited"

task upgrade_node_deps, "Upgrade Node.js dependencies":
  initialNpmInstall()
  exec "npm exec -c 'ncu -ui'"
  exec "npm install"
  echo "NOTE: 'engines' versions in 'package.json' need manually upgraded"