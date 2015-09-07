local url = "http://192.168.0.13/code.lua"

function exec(url)
  local status, req = http.get(url)
  if status == nil then
    print("HTTP error: " .. tostring(req))
    return
  end
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
