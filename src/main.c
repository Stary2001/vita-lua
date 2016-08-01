#include <stub_ffi.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <physfs.h>

#include <stdlib.h>
#include <string.h>
#include <psp2/kernel/processmgr.h>
#include <psp2/kernel/threadmgr.h>
#include <psp2/net/http.h>
#include <psp2/net/net.h>
#include <psp2/sysmodule.h>
#include <debugnet.h>
#include <vita2d.h>
#include <psp2/ctrl.h>

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

void open_ffi(lua_State *l);

int main()
{
	lua_State *lua = luaL_newstate();
	lua_atpanic(lua, panic);

	vita2d_init();
	PHYSFS_init(NULL);

	sceSysmoduleLoadModule(SCE_SYSMODULE_NET);
	SceNetInitParam netInitParam;
	int size = 1024 * 512;
	netInitParam.memory = malloc(size);
	netInitParam.size = size;
	netInitParam.flags = 0;
	sceNetInit(&netInitParam);

	sceSysmoduleLoadModule(SCE_SYSMODULE_HTTP);
	debugNetInit(DEBUGGER_IP, DEBUGGER_PORT, DEBUG);
	sceHttpInit(1024 * 50);

	luaL_openlibs(lua);
	open_ffi(lua);

	lua_pushcfunction(lua, print);
	lua_setglobal(lua, "print");

	/*
	// Display splash
	unsigned int goal = 2*60;
	unsigned int counter = 0;
	vita2d_texture *tex = vita2d_load_PNG_buffer(splash_data);
	SceCtrlData pad;
	memset(&pad, 0, sizeof(pad));
	for (;;) {
		++counter;
		if (counter >= goal)
			break;
		sceCtrlPeekBufferPositive(0, &pad, 1);
		if (pad.buttons & SCE_CTRL_ANY)
			break;
		vita2d_start_drawing();
		vita2d_clear_screen();
		vita2d_draw_texture(tex, 0, 0);
		vita2d_end_drawing();
		vita2d_swap_buffers();
	}
	*/

	if(luaL_loadfile(lua, "app0:lua/init.lua") == 0)
	{
		if(lua_pcall(lua, 0, 0, 0) != 0)
        {
            debugNetPrintf(DEBUG, "init error: %s\n", lua_tostring(lua, -1));
            lua_pop(lua, 1);
        }
	}

	if(luaL_loadfile(lua, "app0:boot.lua") == 0)
	{
		if(lua_pcall(lua, 0, 0, 0) != 0)
		{
			debugNetPrintf(DEBUG, "bootscript err: %s\n", lua_tostring(lua, -1));
			lua_pop(lua, 1);
		}
	}
	else
	{
		debugNetPrintf(DEBUG, "bootscript load err: %s\n", lua_tostring(lua, -1));
		lua_pop(lua, 1);
	}

	sceHttpTerm();
	PHYSFS_deinit();
	vita2d_fini();
	//vita2d_free_texture(tex);

	sceKernelExitProcess(0);
	return 0;
}
