-- vitafm
-- Loads up ui.choose_file and applies magic.
local fsroot = "app0:"
local dir = "/"
local binpath = "/bin"
local confpath = "/vitafm.conf"

vitafm = {}

-- Helpers
local function file_extension(path)
	return tostring(path):match("^.+(%..+)$")
end

-- Config parser. Something like TOML and INI.
local function config_parse(file)
	local c = {}
	local subsect

	if vfs.exists(file) then
		local data = assert(vfs.read(file))
		for n, line in pairs(string.lines(data)) do
			local s = line:match("^%[([^%]]+)%]$")
			if s then
				subsect = s
				c[s] = c[s] or {}
			else
				local t = subsect and c[subsect] or c
				local k, v = line:match("^(.-)%s-=%s-(.+)$")
				if k and v then
					local nv = tonumber(v)
					if v == "true" then
						t[k] = true
					elseif v == "false" then
						t[k] = false
					elseif nv ~= nil then
						t[k] = nv
					else
						t[k] = v
					end
				elseif line ~= "" then
					table.insert(t, line)
				end
			end
		end
		return c
	else
		return nil
	end
end

-- Actual vitafm.programs
function vitafm.lua(file)
	print("Lua file: ".. file)
	if vfs.exists(file) then
		local data = assert(vfs.read(file))
		local fn, err = loadstring(data)
		if err ~= nil then
			print("File manager: Lua syntax error: "..tostring(err))
			--ui.error("lua: Syntax Error", "Error:\n" .. tostring(err))
			error(tostring(err), 0)
			return
		end
		local success, err = pcall(fn)
		if not success then
			print("File manager: Lua script error: "..tostring(err))
			--ui.error("lua: Script Error", "Error:\n" .. tostring(err))
			error(tostring(err), 0)
			return
		end
	else
		--ui.error("lua: Couldn't open File", "Error:\nFile ''" .. file .. "' could not be opened.")
		error("File ''" .. file .. "' could not be opened.")
	end
end

-- Types
vitafm.types = {
	[".lua"] = "lua %f",
	["*"] = "ask %f %e"
}

-- "Program" Registration.
vitafm.programs = {
	["lua"] = vitafm.lua
}

-- Aliases
vitafm.aliases = {}

function vitafm.add_programs(path)
	local dir = vfs.list(path)
	if not dir then return end
	for k, v in pairs(dir) do
		if v:find("%.lua$") then
			local filepath = path.."/"..v
			if vfs.exists(filepath) then
				local data = assert(vfs.read(filepath))
				local fn, err = loadstring(data)
				if err ~= nil then
					print("File manager: Lua plugin load error: "..tostring(err))
				else
					vitafm.programs[v:gsub("%.lua$", "")] = fn
				end
			end
		elseif v:find("%.vsh$") then
			local filepath = path.."/"..v
			if vfs.exists(filepath) then
				local data = assert(vfs.read(filepath))
				local succ, err = vitafm.parse_commands(data, {}, true)
				if not succ then
					print("File manager: vsh script syntax error: "..tostring(err))
				else
					vitafm.programs[v:gsub("%.vsh$", "")] = data
				end
			end
		end
	end
end

function vitafm.exec(prog, ...)
	local f = vitafm.programs[prog]
	if type(f) == "function" then
		f(...)
	elseif type(f) == "string" then
		vitafm.run_command(f, {}, {...})
	elseif f == nil then
		error("No such program.")
	else
		error("No such program: "..prog)
	end
end
function vitafm.exec_vars(prog, vars, ...)
	local f = vitafm.programs[prog]
	if type(f) == "function" then
		f(...)
	elseif type(f) == "string" then
		vitafm.run_command(f, vars, {...})
	elseif f == nil then
		error("No such program.")
	else
		error("No such program: "..prog)
	end
end

-- The tokenizer/backtick parser
function vitafm.parse_commands(command, vars, dryparse)
	local dryparse = dryparse or false
	local res = {}
	local spat, epat, buf, quoted = [=[^(['"`])]=], [=[(['"`])$]=]
	local vars = vars or {}
	local pipeno = 1
	for str in command:gmatch("%S+") do
		res[pipeno] = res[pipeno] or {}
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"`]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then
			buf = buf .. ' ' .. str
		end
		if not buf then
			if dryparse then
				table.insert(res[pipeno], str:gsub(spat,""):gsub(epat,""))
			else
				if quoted == "`" then
					table.insert(res[pipeno], vitafm.run_shell(str:gsub(spat,""):gsub(epat,""), vars))
				elseif str == "|" then
					pipeno = pipeno + 1
				else
					local v = str:gsub(spat,""):gsub(epat,"")
					local val
					local nv = tonumber(val)
					if v == "true" then
						val = true
					elseif v == "false" then
						val = false
					elseif nv ~= nil then
						val = nv
					else
						local tmp = v
						for varname, replacement in pairs(vars) do
							--tmp = tmp:gsub(varname:gsub("%%", "%%%1"), replacement)
							tmp = tmp:gsub(varname, replacement)
						end
						val = tmp
					end
					table.insert(res[pipeno], val)
				end
			end
		end
	end
	if buf then
		return false, "Missing matching quote for "..buf
	end
	return true, res
end

function vitafm.escape_args(command)
	local res = ""
	for k, v in pairs(command) do
		if type(v) == "string" then
			res = res + "'" + v:gsub("\\", "\\\\"):gsub("'", "\\'") + "'" + " "
		elseif type(v) == "number" then
			res = res + tostring(v) + " "
		elseif v == true or v == false then
			res = res + tostring(v) + " "
		end
	end
	return string.strip(res)
end

function vitafm.run_command(command, vars, appendedargs)
	local vars = vars or {}
	local succ, pipes = vitafm.parse_commands(command, vars)
	if not succ then
		ui.error("Command Parser Error", "Error:\n" .. split)
		return
	end
	local res
	local pipelen = #pipes
	for no, cmd in pairs(pipes) do
		if no == pipelen then
			if appendedargs then
				for k, v in pairs(appendedargs) do
					table.insert(cmd, v)
				end
			end
		else
			if res ~= nil then
				table.insert(cmd, res)
				res = nil
			end
		end
		local prog = cmd[1]
		table.remove(cmd, 1)

		if vitafm.programs[prog] then
			local succ, ret = pcall(vitafm.exec_vars, prog, vars, unpack(cmd))
			if not succ then
				print("Program "..prog.." errored: "..ret)
				ui.error("Error in program "..prog, ret)
			else
				res = ret
			end
		elseif vitafm.aliases[prog] then
			res = vitafm.run_shell(vitafm.aliases[prog], vars, cmd)
		else
			error("No such program.")
		end
		if no == pipelen then
			return res
		end
	end
end
function vitafm.run_shell(code, vars, appendedargs)
	local res
	if code then
		local lines = string.lines(code)
		local len = #lines
		for k, line in pairs(lines) do
			if k == len then
				res = vitafm.run_command(line, vars, appendedargs)
			else
				vitafm.run_command(line, vars)
			end
		end
	end
end

-- Handy aliases.
vitafm.sh = vitafm.run_shell
sh = vitafm.run_shell

local function call_prog(command, file, ext)
	return vitafm.run_shell(command, {
		["%%f"] = file,
		["%%F"] = fsroot..file,
		["%%e"] = ext
	})
end

-- Ask for program to launch it with.
function vitafm.ask(file, ext)
	if not string.find(file or "", "^/") then
		return
	end
	local ext = ext or file_extension(file)
	local keys = {}
	local i = 0
	local sel = 1
	for k, v in pairs(vitafm.types) do
		if k ~= "*" then
			i = i + 1
			if k == ext then
				sel = i
			end
			table.insert(keys, k .. " - " .. v)
		end
	end
	local l = #keys
	keys[l+1] = nil
	keys[l+2] = "Open with..."
	keys[l+3] = "Back"
	while true do
		opt = ui.choose(keys, "Launch as... (Extension: ".. (ext or "none") .. ")", sel)
		if opt then
			res = opt:gsub(" - .-$", "")
			if opt == "Back" then
				return
			elseif opt == "Open with..." then
				prog = ui.choose(table.keys(vitafm.programs), "Open with...")
				if prog then
					return call_prog(prog.." %f", file)
				end
				return
			elseif vitafm.types[res] then
				return call_prog(vitafm.types[res], file, res)
			end
		else
			return
		end
	end
end
vitafm.programs["ask"] = vitafm.ask

-- Parse Config
function vitafm.parse_config(path)
	print("Looking for config...")
	if vfs.exists(path) then
		print("Loading config...")
		local conf = config_parse(path)
		if type(conf.filetypes) == "table" then
			for k, v in pairs(conf.filetypes) do
				vitafm.types[k] = v
			end
		end
		if type(conf.aliases) == "table" then
			vitafm.aliases = conf.aliases
		end
		print("Loaded config.")
	else
		print("Not found.")
	end
end

local pad = input.peek()
if not (pad:l_trigger() or pad:r_trigger()) then
	vitafm.parse_config(confpath)
end

-- Main loop.
function vitafm.run()
	print("vitafm.run()")
	local selected
	while true do
		if vfs.isdir(binpath) then
			vitafm.add_programs(binpath)
		end
		print("vitafm: added programs")
		file, dir, selected = ui.choose_file(dir, nil, selected, (function(sel, old_pad, pad, path)
			print("hook")
			if old_pad:triangle() and not pad:triangle() then -- "Open as" menu
				vitafm.programs["ask"](path, file_extension(path))
				return true, nil
			elseif old_pad:square() and not pad:square() then -- Tool menu
				local title = "VitaFM Menu"
				local menuitems = {
					"Run Program",
					nil,
					"Reload Config",
					"Exit VitaFM",
					"Back"
				}
				res = ui.choose(menuitems, title)
				if res == "Run Program" then
					prog = ui.choose(table.keys(vitafm.programs), "Open Program...")
					if prog then
						local succ, ret = pcall(vitafm.exec, prog)
						if not succ then
							print("Program "..prog.." errored: "..ret)
							ui.error("Error in program "..prog, ret)
						else
							return ret
						end
					end
				elseif res == "Reload Config" then
					vitafm.parse_config(confpath)
				elseif res == "Exit VitaFM" then
					uvl.exit(0)
				end
				return true, nil
			end
		end))
		if file ~= nil then
			local ext = file_extension(file)
			if vitafm.types[ext] then
				call_prog(vitafm.types[ext], file, ext)
			elseif vitafm.types["*"] then
				call_prog(vitafm.types["*"], file, ext)
			end
		end
	end
end
