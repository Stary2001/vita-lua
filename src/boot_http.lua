local url = "http://stary2001.co.uk/lua/boot.lua"

http.init()

function exec(url)
  local status, req = http.get(url)
  if req == nil then return end
  local code = req:read("*a")
  req:close()

  print("Loading code...")
  local func, err = loadstring(code)
  if func == nil then
    print("Error: "..err)
    return
  end
  local success, err = pcall(func)
  if not success then
    print("Error: "..err)
  end
end

exec(url)

http.term()
