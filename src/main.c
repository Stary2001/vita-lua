#include <psp2/kernel/processmgr.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <debugnet.h>

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

void open_vita2d(lua_State *l);
void open_input(lua_State *l);

int main()
{
	debugNetInit(DEBUGGER_IP, DEBUGGER_PORT, DEBUG);
	debugNetPrintf(DEBUG, "creating\n");
	lua_State *lua = luaL_newstate();
	lua_atpanic(lua, panic);

	debugNetPrintf(DEBUG, "openlibs\n");
	luaL_openlibs(lua);
	debugNetPrintf(DEBUG, "newlib\n");
	open_vita2d(lua);
	open_input(lua);

	lua_pushcfunction(lua, print);
	lua_setglobal(lua, "print");
	debugNetPrintf(DEBUG, "load\n");
	luaL_loadstring(lua, "vita2d.init()\n f = vita2d.load_font_file(\"cache0:/VitaDefilerClient/Documents/DejaVuSans.ttf\")\n while true do\n if input.is_pressed(button.start) then break end\n vita2d.start_drawing()\n vita2d.draw_text(f, 10 ,20 ,0xffffffff, 20, 'Hello Moon!')\n vita2d.end_drawing()\n vita2d.swap_buffers()\n end\n vita2d.fini()");
	debugNetPrintf(DEBUG, "call\n");
	if(lua_pcall(lua, 0, 0, 0) != LUA_OK)
	{
		debugNetPrintf(DEBUG, "err: %s\n", lua_tostring(lua, -1));
	}
	debugNetPrintf(DEBUG, "calld\n");

	sceKernelExitProcess(0);
	return 0;
}
