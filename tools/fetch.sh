#!/bin/bash
# -*- shell-script -*-

# Fetch tools from luatools directory:

LUATOOLS=(
  BeautifulTbl.lua
  Dbg.lua
  Optiks.lua
  Optiks_Option.lua
  Stencil.lua
  TermWidth.lua
  capture.lua
  declare.lua
  fileOps.lua
  inherits.lua
  pairsByKeys.lua
  serializeTbl.lua
  string_utils.lua
  strict.lua
)

LUATOOLS_DIR=$HOME/w/luatools/modules
HERMES_TOOLS_DIR=$HOME/w/hermes/tools

for i in "${LUATOOLS[@]}"; do
  cp $LUATOOLS_DIR/$i $HERMES_TOOLS_DIR
done

