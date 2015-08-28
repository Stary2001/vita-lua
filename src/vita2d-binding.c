#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <vita2d.h>
#include <debugnet.h>

int bind_vita2d_init(lua_State *l)
{
	vita2d_init();
	return 0;
}

int bind_vita2d_fini(lua_State *l)
{
	vita2d_fini();
	return 0;
}

int bind_vita2d_start_drawing(lua_State *l)
{
        vita2d_start_drawing();
        return 0;
}

int bind_vita2d_end_drawing(lua_State *l)
{
        vita2d_end_drawing();
        return 0;
}

int bind_vita2d_swap_buffers(lua_State *l)
{
        vita2d_swap_buffers();
        return 0;
}

int bind_vita2d_draw_rectangle(lua_State *l)
{
	int x = luaL_checkinteger(l, 1);
	int y = luaL_checkinteger(l, 2);
	int w = luaL_checkinteger(l, 3);
	int h = luaL_checkinteger(l, 4);
	unsigned int color = (unsigned int)luaL_checkinteger(l, 5); 
	vita2d_draw_rectangle(x, y, w, h, color);
	return 0;
}

int bind_vita2d_load_font_file(lua_State *l)
{
	vita2d_font *f = vita2d_load_font_file(luaL_checkstring(l, 1));
	if(f != NULL)
	{
		lua_pushlightuserdata(l, f);
	}
	else
	{
		lua_pushnil(l);
	}

	return 1;
}

int bind_vita2d_draw_text(lua_State *l)
{
	luaL_checktype(l, 1, LUA_TLIGHTUSERDATA);
	vita2d_font *f = (vita2d_font*) lua_touserdata(l, 1);
	vita2d_font_draw_text(f, luaL_checkinteger(l, 2), luaL_checkinteger(l, 3), (unsigned int)luaL_checkinteger(l, 4), luaL_checkinteger(l, 5), luaL_checkstring(l, 6));
	return 0;
}

const luaL_Reg vita2d[] =
{
	{"init", bind_vita2d_init},
	{"fini", bind_vita2d_fini},
	{"load_font_file", bind_vita2d_load_font_file},
	{"draw_text", bind_vita2d_draw_text},
	{"start_drawing", bind_vita2d_start_drawing},
	{"end_drawing", bind_vita2d_end_drawing},
	{"draw_rectangle", bind_vita2d_draw_rectangle},
	{"swap_buffers", bind_vita2d_swap_buffers},
	{NULL, NULL}
};

void open_vita2d(lua_State *lua)
{
	debugNetPrintf(DEBUG, "newlib\n");
	luaL_newlib(lua, vita2d);
	debugNetPrintf(DEBUG, "setglobal\n");
	lua_setglobal(lua, "vita2d");
}
