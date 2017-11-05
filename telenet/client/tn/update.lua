-- Auto-update client files

local serialization = require"serialization"
local component     = require"component"
local fs            = require"filesystem"
local tn            = require"telenet"
local gpu           = component.gpu

local unpack = table.unpack
local insert = table.insert
local ip, err

ip, err = tn.getIP()
if not ip then io.stderr:write("Ошибка при обновлении Telenet:\n"..err.."\n");return end



local function getFromUpdate(fncName, name)
  local sender, msg = tn.sendrec("update", "update", fncName, name)
  local unsr = serialization.unserialize(msg)
  return unsr and unpack(unsr) or msg
end


local function setColor(c)
  if gpu.getForeground() ~= c then
    gpu.setForeground(c)
  end
end

local function write_c(c, ...)
  local oldCol = gpu.getForeground()
  setColor(c)
  io.write(...)
  setColor(oldCol)
end



local args = {...}
local isInstall = (args[1]=="install")
if isInstall then
  -- We loading this file from installer
  write_c(0x44FF55,"Файлы установки успешно загружены!\n")
  write_c(0xffffff,"Дополнительно файлов к закачке: ")
else
end


local fileList = getFromUpdate("getFileList", "client/")
if not fileList then 
  --io.stderr:write("Сервер обновлений не выдал файлов\n")
  return
end

-- Check files size to determine whats new
local filesToLoad={}
for _, fl in ipairs(fileList) do
  if fs.size(fl.path) ~= fl.size then
    insert(filesToLoad, fl.path)
  end
end

if #filesToLoad > 0 then
  if isInstall then
    write_c(0x4455FF, #filesToLoad.."\n")
  else
    write_c(0xffffff, "Обновление Telenet. Всего файлов: "..#filesToLoad.."\n")
  end
else
  return
end



local function writeFile(path, content)
  -- Create folder
  local fFolder = fs.path(path)
  if not fs.exists(fFolder) then
    fs.makeDirectory(fFolder)
  end
  
  -- Write content in file
  local f, err = io.open(path, "w")
  if not f then
    write_c(0xff0000, "Ошибка: ")
    write_c(0x690000, err)
    return false
  end
  f:write(content)
  f:close()
  if isInstall then write_c(0x44FF55, "ok\n") end
end


for _, fl in ipairs(filesToLoad) do
  if isInstall then write_c(0x4455FF, fl.."...") end
  -- Get file content from server
  local fileContent = getFromUpdate("getFile", "client/"..fl)
  
  writeFile(fl, fileContent)
  
  -- Do boot files
  if fs.path(fl) == "boot/" then
    local ok, err = pcall(loadfile(fl), "install")
    if not ok then
      write_c(0xcaaa88, "Почему то не запустился файл "..fl.."\n")
      write_c(0xcaaa88, err.."\n")
    end
  end
end

if isInstall then write_c(0x44FF55,"Telenet готов к работе!") end