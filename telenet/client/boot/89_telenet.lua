-- Add computer path and run update

local shell = require"shell"
shell.setPath(shell.getPath() .. ":/tn")

local args = {...}
if args[1] ~= "install" then
  local updatePath = "tn/update.lua"
  local f = loadfile(updatePath)
  if f then 
    local ok, err = pcall(f,"boot")
    if not ok then io.stderr:write(err.."\n") end
  end
end