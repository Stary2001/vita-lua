#ifdef JIT
#include <stub_ffi.h>
#endif

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <psp2/kernel/processmgr.h>
#include <psp2/kernel/threadmgr.h>
#include <debugnet.h>
#include <vita2d.h>

#define DEBUGGER_IP "192.168.0.13"
#define DEBUGGER_PORT 18194

int panic(lua_State *l)
{
	debugNetPrintf(DEBUG, "Lua paniced with '%s!'\n", lua_tostring(l, -1));
	sceKernelExitProcess(0);
	return 0;
}

int print(lua_State *l)
{
	debugNetPrintf(DEBUG, "[Lua] %s\n", lua_tostring(l, -1));
	return 0;
}

int os_sleep(lua_State *l)
{
	sceKernelDelayThread((unsigned int)(luaL_checknumber(l, 1) * 1000000));
	return 0;
}

void test()
{
	debugNetPrintf(DEBUG, "Hello, C!\n");
}

#ifndef JIT
void open_vita2d(lua_State *l);
void open_input(lua_State *l);
void open_http(lua_State *l);
#endif

int main()
{
	#ifdef JIT
		Function funcs[] = 
		{
			{"test", test},
			{NULL, NULL}
		};
		FunctionTable table = { .funcs = funcs, .next = NULL };
		ffi_add_table(&table);
	#endif

	debugNetInit(DEBUGGER_IP, DEBUGGER_PORT, DEBUG);
	debugNetPrintf(DEBUG, "creating\n");
	lua_State *lua = luaL_newstate();
	lua_atpanic(lua, panic);

	luaL_openlibs(lua);
	#ifndef JIT
	open_vita2d(lua);
	open_input(lua);
	open_http(lua);
	#endif

	lua_pushcfunction(lua, print);
	lua_setglobal(lua, "print");
	
	lua_getglobal(lua, "os");
	lua_pushstring(lua, "sleep");
	lua_pushcfunction(lua, os_sleep);
	lua_rawset(lua, -3);
	lua_pop(lua, 1);

	luaL_loadfile(lua, "cache0:/VitaDefilerClient/Documents/http.lua");
	if(lua_pcall(lua, 0, 0, 0) != 0)
	{
		debugNetPrintf(DEBUG, "err: %s\n", lua_tostring(lua, -1));
	}
	debugNetPrintf(DEBUG, "calld\n");
	
	sceKernelExitProcess(0);
	return 0;
}
