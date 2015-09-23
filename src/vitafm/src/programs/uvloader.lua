-- uvloader.lua
local args = {...}
if args[1] then
	vita2d.fini() -- Deinitialize vita2d, so that graphics aren't messed up.

	local status = uvl.load(args[1])

	os.sleep(0.5) -- Take our time, so that we don't accidentally select a bad thing.
	vita2d.init() -- Initialize that thing again.
	vita2d.clear_screen()
	os.sleep(0.5)
	return status
else
	error("Usage: uvloader homebrew.velf")
end
