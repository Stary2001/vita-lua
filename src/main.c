#include <stub_ffi.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <physfs.h>

#include <string.h>
#include <psp2/kernel/processmgr.h>
#include <psp2/kernel/threadmgr.h>
#include <psp2/net/http.h>
#include <debugnet.h>
#include <vita2d.h>

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

const char *bootscript_data;
const char *defaultfont_data;
unsigned int defaultfont_data_len;
void open_ffi(lua_State *l);

int main()
{
	debugNetInit(DEBUGGER_IP, DEBUGGER_PORT, DEBUG);
	debugNetPrintf(DEBUG, "creating\n");
	lua_State *lua = luaL_newstate();
	lua_atpanic(lua, panic);

	vita2d_init();
	PHYSFS_init(NULL);
	sceHttpInit(100);

	luaL_openlibs(lua);
	open_ffi(lua);

	lua_getglobal(lua, "vita2d");
	lua_pushstring(lua, "default_font_data");
	lua_pushlstring(lua, defaultfont_data, defaultfont_data_len);
	lua_settable(lua, -3);

	lua_pushcfunction(lua, print);
	lua_setglobal(lua, "print");

	if(luaL_loadstring(lua, bootscript_data) == 0)
	{
		if(lua_pcall(lua, 0, 0, 0) != 0)
		{
			debugNetPrintf(DEBUG, "bootscript err: %s\n", lua_tostring(lua, -1));
			lua_pop(lua, 1);
		}
	}
	else
	{
		debugNetPrintf(DEBUG, "bootscript err: %s\n", lua_tostring(lua, -1));
		lua_pop(lua, 1);
	}

	sceHttpTerm();
	PHYSFS_deinit();
	vita2d_fini();

	sceKernelExitProcess(0);
	return 0;
}
