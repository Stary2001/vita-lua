local url = ""

http.init()

function exec(url)
  local data = http.get(url)
  print("Loading code...")
  local func, err = loadstring(data)
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
