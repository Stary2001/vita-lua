#ifndef JIT
#include <lua.h>
#include <lauxlib.h>

#include <debugnet.h>
#include <stdlib.h>
#include <psp2/net/http.h>

int bind_sceHttpInit(lua_State *l)
{
	sceHttpInit(1000);
	return 0;
}

int bind_sceHttpTerm(lua_State *l)
{
	sceHttpTerm();
	return 0;
}

int bind_sceHttpCreateTemplate(lua_State *l)
{
	int templ = sceHttpCreateTemplate(luaL_checkstring(l, 1), PSP2_HTTP_VERSION_1_1, 0);
	lua_pushinteger(l, templ);
	return 1;
}

int bind_sceHttpCreateConnection(lua_State *l)
{
	int conn = sceHttpCreateConnection(luaL_checkinteger(l, 1), luaL_checkstring(l, 2), luaL_checkstring(l, 3), (unsigned short)luaL_checkinteger(l, 4), lua_toboolean(l, 5));
	lua_pushinteger(l, conn);
	return 1;
}

int bind_sceHttpCreateConnectionWithURL(lua_State *l)
{
	int conn = sceHttpCreateConnectionWithURL(luaL_checkinteger(l, 1), luaL_checkstring(l, 2), lua_toboolean(l, 5));
	lua_pushinteger(l, conn);
	return 1;
}

int bind_sceHttpDeleteConnection(lua_State *l)
{
	sceHttpDeleteConnection(luaL_checkinteger(l, 1));
	return 0;
}

int bind_sceHttpCreateRequest(lua_State *l)
{
	int meth = PSP2_HTTP_METHOD_GET;
	int req = sceHttpCreateRequest(luaL_checkinteger(l, 1), meth, luaL_checkstring(l, 2), luaL_checkinteger(l, 3));
	lua_pushinteger(l, req);
	return 1;
}

int bind_sceHttpCreateRequestWithURL(lua_State *l)
{
        int meth = PSP2_HTTP_METHOD_GET;
        int req = sceHttpCreateRequestWithURL(luaL_checkinteger(l, 1), meth, luaL_checkstring(l, 2), luaL_checkinteger(l, 3));
        lua_pushinteger(l, req);
        return 1;
}

int bind_sceHttpDeleteRequest(lua_State *l)
{
	sceHttpDeleteRequest(luaL_checkinteger(l, 1));
	return 0;
}

int bind_sceHttpSendRequest(lua_State *l)
{
	sceHttpSendRequest(luaL_checkinteger(l, 1), NULL, 0);
	return 0;
}

int bind_http_read_data(lua_State *l)
{
	int req = luaL_checkinteger(l, 1);
	unsigned long long len = 0;
	sceHttpGetResponseContentLength(req, &len);
	char *data = malloc(len);
	sceHttpReadData(req, data, len);
	lua_pushlstring(l, data, len);
	free(data);
	return 1;
}

const luaL_Reg http[] =
{
	{"init", bind_sceHttpInit},
	{"term", bind_sceHttpTerm},
	{"create_template", bind_sceHttpCreateTemplate},
	{"create_connection", bind_sceHttpCreateConnection},
	{"create_connection_with_url", bind_sceHttpCreateConnectionWithURL},
	{"create_request", bind_sceHttpCreateRequest},
	{"create_request_with_url", bind_sceHttpCreateRequestWithURL},
	{"send_request", bind_sceHttpSendRequest},
	{"delete_connection", bind_sceHttpDeleteConnection},
	{"delete_request", bind_sceHttpDeleteRequest},
	{"read_data", bind_http_read_data},
	{NULL, NULL}
};

void open_http(lua_State *lua)
{
#ifdef JIT
	luaL_register(lua, "http", http);
#else
	luaL_newlib(lua, http);
	lua_setglobal(lua, "http");
#endif
}
#endif
