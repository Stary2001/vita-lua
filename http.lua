http.init()
tmpl = http.create_template("abcd")

function r(url)
  conn = http.create_connection_with_url(tmpl, url, true)
  req = http.create_request_with_url(conn, url, 0)
  http.send_request(req)
  code = http.read_data(req)
  http.delete_request(req)
  http.delete_connection(conn)
  return code
end

ip = ""

while true do
  f,e = load(r("http://"..ip.."/code.lua"))
  if f == nil then
    print(tostring(e))
  else
    f()
  end
  while true do if input.is_pressed(button.select) then break end os.sleep(1) end
  if input.is_pressed(button.start) then break end 
  os.sleep(1)
end
http.delete_connection(conn)
http.term()
