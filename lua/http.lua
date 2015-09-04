-- http
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

local C = ffi.C

local messages =
{
  -2143088639 = "BEFORE_INIT",
  -2143088608 = "ALREADY_INITED",
  -2143088607 = "BUSY",
  -2143088606 = "OUT_OF_MEMORY",
  -2143088603 = "NOT_FOUND",
  -2143088534 = "INVALID_VERSION",
  -2143088384 = "INVALID_ID",
  -2143088380 = "OUT_OF_SIZE",
  -2143088130 = "INVALID_VALUE",
  -2143080352 = "INVALID_URL",
  -2143088543 = "UNKNOWN_SCHEME",
  -2143088541 = "NETWORK",
  -2143088540 = "BAD_RESPONSE",
  -2143088539 = "BEFORE_SEND",
  -2143088538 = "AFTER_SEND",
  -2143088536 = "TIMEOUT",
  -2143088535 = "UNKOWN_AUTH_TYPE",
  -2143088533 = "UNKNOWN_METHOD",
  -2143088529 = "READ_BY_HEAD_METHOD",
  -2143088528 = "NOT_IN_COM",
  -2143088527 = "NO_CONTENT_LENGTH",
  -2143088526 = "CHUNK_ENC",
  -2143088525 = "TOO_LARGE_RESPONSE_HEADER",
  -2143088523 = "SSL",
  -2143088512 = "ABORTED",
  -2143088511 = "UNKNOWN",
  -2143084507 = "PARSE_HTTP_NOT_FOUND",
  -2143084448 = "PARSE_HTTP_INVALID_RESPONSE",
  -2143084034 = "PARSE_HTTP_INVALID_VALUE",
  -2143068159 = "RESOLVER_EPACKET",
  -2143068158 = "RESOLVER_ENODNS",
  -2143068157 = "RESOLVER_ETIMEDOUT",
  -2143068156 = "RESOLVER_ENOSUPPORT",
  -2143068155 = "RESOLVER_EFORMAT",
  -2143068154 = "RESOLVER_ESERVERFAILURE",
  -2143068153 = "RESOLVER_ENOHOST",
  -2143068152 = "RESOLVER_ENOTIMPLEMENTED",
  -2143068151 = "RESOLVER_ESERVERREFUSED",
  -2143068150 = "RESOLVER_ENORECORD"
}

http = {}
local template

local req_mt =
{
  __index =
  {
    len = function(self)
      local len = ffi.new("uint64_t[1]")
      C.sceHttpGetResponseContentLength(self.req, len)
      return tonumber(len[0])
    end,

    read = function(self, spec)
      local len
      if spec == "*all" or spec == "*a" or spec == nil then
        len = self:len()
      elseif type(spec) == "number" then
        len = spec
      else
        error("invalid read() specification")
      end
      local buf = ffi.new("uint8_t[?]", len)
      local r = C.sceHttpReadData(self.req, buf, len)
      if r < 0 then
        return nil, messages[r]
      end
      return ffi.string(buf, len)
    end,

    close = function(self)
      C.sceHttpDeleteRequest(self.req)
      C.sceHttpDeleteConnection(self.conn)
    end
  }
}

function http.init()
  C.sceHttpInit(100)
end

function http.term()
  C.sceHttpTerm()
end

function http.request(meth, url, post_data)
  if meth == "get" then
    meth = C.PSP2_HTTP_METHOD_GET
  elseif meth == "post" then
    meth = C.PSP2_HTTP_METHOD_POST
  else return end

  if template == nil then
    template = C.sceHttpCreateTemplate("VitaLua", C.PSP2_HTTP_VERSION_1_1, 0)
  end

  local conn = C.sceHttpCreateConnectionWithURL(template, url, 0)
  if conn == 0 then
    return nil, "createConnection failed"
  end

  local req = C.sceHttpCreateRequestWithURL(conn, meth, url, post_data and #post_data or 0)
  if req == 0 then
    return nil, "createRequest failed"
  end

  local r = C.sceHttpSendRequest(req, post_data, post_data and #post_data or 0)
  if r < 0 then
    return nil, messages[r]
  end
  local status = ffi.new('int[1]')
  r = C.sceHttpGetStatusCode(req, status)
  if r < 0 then
    C.sceHttpDeleteRequest(req)
    C.sceHttpDeleteConnection(conn)
    return nil, messages[r]
  end

  local r = { req = req, conn = conn }
  setmetatable(r, req_mt)
  return status[0], r
end

function http.get(url)
  return http.request("get", url, nil)
end

function http.post(url, post_data)
  return http.request("post", url, post_data)
end
