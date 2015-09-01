local ffi = require 'ffi'

ffi.cdef [[
typedef enum {
        PSP2_HTTP_VERSION_1_0 = 1,
        PSP2_HTTP_VERSION_1_1
} SceHttpHttpVersion;

typedef enum {
        PSP2_HTTP_METHOD_GET,
        PSP2_HTTP_METHOD_POST,
        PSP2_HTTP_METHOD_HEAD,
        PSP2_HTTP_METHOD_OPTIONS,
        PSP2_HTTP_METHOD_PUT,
        PSP2_HTTP_METHOD_DELETE,
        PSP2_HTTP_METHOD_TRACE,
        PSP2_HTTP_METHOD_CONNECT
} SceHttpMethods;

int sceHttpInit(unsigned int poolSize);
int sceHttpTerm(void);
int sceHttpCreateTemplate(const char *userAgent, int httpVer, int autoProxyConf);
int sceHttpDeleteTemplate(int tmplId);
int sceHttpCreateConnection(int tmplId, const char *serverName, const char *scheme, unsigned short port, int enableKeepalive);
int sceHttpCreateConnectionWithURL(int tmplId, const char *url, int enableKeepalive);
int sceHttpDeleteConnection(int connId);
int sceHttpCreateRequest(int connId, int method, const char *path, unsigned long long int contentLength);
int sceHttpCreateRequestWithURL(int connId, int method, const char *url, unsigned long long int contentLength);
int sceHttpDeleteRequest(int reqId);

int sceHttpSendRequest(int reqId, const void *postData, unsigned int size);
int sceHttpAbortRequest(int reqId);
int sceHttpGetResponseContentLength(int reqId, unsigned long long int *contentLength);
int sceHttpGetStatusCode(int reqId, int *statusCode);
int sceHttpGetAllResponseHeaders(int reqId, char **header, unsigned int *headerSize);
int sceHttpReadData(int reqId, void *data, unsigned int size);
int sceHttpAddRequestHeader(int id, const char *name, const char *value, unsigned int mode);
int sceHttpRemoveRequestHeader(int id, const char *name);
]]

http = {}
local template

function http.init()
  ffi.C.sceHttpInit(100)
end

function http.term()
  ffi.C.sceHttpTerm()
end

function http.request(meth, url, post_data)
  local C = ffi.C
  if meth == "get" then
    meth = C.PSP2_HTTP_METHOD_GET
  elseif meth == "post" then
    meth = C.PSP2_HTTP_METHOD_POST
  else return end

  if template == nil then
    template = C.sceHttpCreateTemplate("VitaLua", C.PSP2_HTTP_VERSION_1_1, 0)
  end

  local conn = C.sceHttpCreateConnectionWithURL(template, url, 0)
  local req = C.sceHttpCreateRequestWithURL(conn, C.PSP2_HTTP_METHOD_GET, url, post_data and #post_data or 0)
  if C.sceHttpSendRequest(req, post_data, post_data and #post_data or 0) < 0 then
    print("err")
    return nil
  end
  local len = ffi.new("uint64_t[1]")
  C.sceHttpGetResponseContentLength(req, len)
  len = tonumber(len[0])
  local buf = ffi.new("uint8_t[?]", len)
  C.sceHttpReadData(req, buf, len)
  local s = ffi.string(buf, len)
  C.sceHttpDeleteRequest(req)
  C.sceHttpDeleteConnection(conn)
  return s
end

function http.get(url)
  return http.request("get", url, nil)
end

function http.post(url, post_data)
  return http.request("post", url, post_data)
end
