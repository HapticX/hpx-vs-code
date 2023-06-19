## Used by various features (`nim*` files) as a catch-all file for common procs

import
  platform/vscodeApi,
  platform/js/[jsNodeFs, jsNodePath, jsString],
  std/[jscore, strformat, sequtils, hashes],
  spec

var ext*: ExtensionState


template extensionContext(): VscodeExtensionContext = ext.ctx
template channel(): VscodeOutputChannel = ext.channel


proc isSubpath(parent, child: cstring): bool =
  result =
    if process.platform == "win32":
      child.toLowerAscii.startsWith(parent.toLowerAscii)
    else:
      child.startsWith(parent.toLowerAscii)


proc isWorkspaceFile*(filePath: cstring): bool =
  ## Returns true if filePath is related to any workspace file
  ## assumes filePath is absolute
  if vscode.workspace.workspaceFolders.toJs().to(bool):
    vscode.workspace.workspaceFolders
      .anyIt(it.uri.scheme == "file" and isSubpath(it.uri.fsPath, filePath))
  else:
    false


proc removeDirSync(p: cstring) =
  if fs.existsSync(p):
    for entry in fs.readdirSync(p):
      var curPath = path.resolve(p, entry)
      if fs.lstatSync(curPath).isDirectory():
        removeDirSync(curPath)
      else:
        fs.unlinkSync(curPath)
    fs.rmdirSync(p)


proc getDirtyFileFolder*(nimsuggestPid: cint): cstring =
  path.join(extensionContext.storagePath, "vscodenimdirty_" & cstring($nimsuggestPid))


proc cleanupDirtyFileFolder*(nimsuggestPid: cint) =
  removeDirSync(getDirtyFileFolder(nimsuggestPid))


proc getDirtyFile*(nimsuggestPid: cint, filepath, content: cstring): cstring =
  ## temporary file path of edited document
  ## for each nimsuggest instance each file has a unique dirty file
  var dirtyFilePath = path.normalize(
      path.join(getDirtyFileFolder(nimsuggestPid), cstring($int(hash(filepath))) & ".nim")
  )
  fs.writeFileSync(dirtyFilePath, content)
  dirtyFilePath


proc getDirtyFile*(doc: VscodeTextDocument): cstring =
  ## temporary file path of edited document
  ## returns always the same file, so it shouldn't
  ## be used for nimsuggest, only nimpretty!
  var dirtyFilePath = path.normalize(
      path.join(extensionContext.storagePath, "vscodenimdirty.nim")
  )
  fs.writeFileSync(dirtyFilePath, doc.getText())
  dirtyFilePath


proc padStart(len: cint, input: cstring): cstring =
  cstring("0").repeat(input.len) & input


proc cleanDateString(date: DateTime): cstring =
  var
    year = date.getFullYear()
    month = padStart(2, cstring($(date.getMonth())))
    dd = padStart(2, cstring($(date.getDay())))
    hour = padStart(2, cstring($(date.getHours())))
    minute = padStart(2, cstring($(date.getMinutes())))
    second = padStart(2, cstring($(date.getSeconds())))
    milliseconds = padStart(3, cstring($(date.getMilliseconds())))
  fmt"{year}-{month}-{dd} {hour}:{minute}:{second}.{milliseconds}"


proc outputLine*(message: cstring) =
  ## Prints message in Nim's output channel
  channel.appendLine(fmt"{cleanDateString(newDate())} - {message}".cstring)

