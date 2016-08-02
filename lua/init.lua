-- Load libraries sufficient to load the rest.
package.path = "app0:/lib/?.lua;app0:/lib/?/init.lua"
print("init: Loading basic libs...")
require("fs")
ltn12 = require("ltn12")
vfs = require("vfs")

-- Initalize VFS
print("init: vfs: Initializing physfs-ffi and mounting app0, ux0, ur0...")
vfs.loadbackends("physfs-ffi")
vfs.new("app0", "physfs", "app0:/")
vfs.new("ux0", "physfs", "ux0:/")
vfs.new("ur0", "physfs", "ur0:/")

vfs.set_default_drive("app0")
vfs.searchpath("app0:/lib/?.lua;app0:/lib/?/init.lua")

table.insert(package.loaders, 2, vfs.loader)

-- Load remaining libs
local libs = {"audio", "battery", "colors", "hash", "http", "input", "misc", "touch", "ui", "vita2d", "vitafm"}
for _, lib in pairs(libs) do
	print("Loading "..lib.."...")
	require(lib)
end

-- Load bootscript
print("init: Trying to load app0:/boot.lua")
local suc, err = pcall(dofile, "app0:/boot.lua")
if not suc then
	print("Error: "..tostring(err))
end
