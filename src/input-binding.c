#ifndef JIT
#include <lua.h>
#include <lauxlib.h>

#include <debugnet.h>

#include <psp2/ctrl.h>

int input_is_pressed(lua_State *l)
{
	SceCtrlData pad;
	sceCtrlPeekBufferPositive(0, &pad, 1);
	if(pad.buttons & luaL_checkinteger(l, 1))
	{
		lua_pushboolean(l, 1);
	}
	else
	{
		lua_pushboolean(l, 0);
	}
	return 1;
}


int bind_peek(lua_State *l)
{
	SceCtrlData pad;
	sceCtrlPeekBufferPositive(0, &pad, 1);
	lua_newtable(l);

	lua_pushstring(l, "buttons");
	lua_pushinteger(l, pad.buttons);
	lua_rawset(l, -3);

	lua_pushstring(l, "lstick_x");
	lua_pushinteger(l, pad.lx);
	lua_rawset(l, -3);

	lua_pushstring(l, "lstick_y");
	lua_pushinteger(l, pad.ly);
	lua_rawset(l, -3);

	lua_pushstring(l, "rstick_x");
	lua_pushinteger(l, pad.rx);
	lua_rawset(l, -3);

	lua_pushstring(l, "rstick_y");
	lua_pushinteger(l, pad.ry);
	lua_rawset(l, -3);

	return -1;
}

const luaL_Reg input[] =
{
	{"is_pressed", input_is_pressed},
	{"peek", bind_peek},
	{NULL, NULL}
};

#define setint(l,a,b) lua_pushstring(l, a); lua_pushinteger(l, b); lua_rawset(l, -3);

void open_input(lua_State *lua)
{
#if JIT
	luaL_register(lua, "input", input);
#else
	luaL_newlib(lua, input);
	lua_setglobal(lua, "input");
#endif
	lua_newtable(lua);
        setint(lua, "select", PSP2_CTRL_SELECT);
        setint(lua, "start",  PSP2_CTRL_START);
        setint(lua, "up", PSP2_CTRL_UP);
        setint(lua, "right", PSP2_CTRL_RIGHT);
        setint(lua, "down", PSP2_CTRL_DOWN);
	setint(lua, "left", PSP2_CTRL_LEFT);
        setint(lua, "l_trigger", PSP2_CTRL_LTRIGGER);
        setint(lua, "r_trigger", PSP2_CTRL_RTRIGGER);
        setint(lua, "triangle", PSP2_CTRL_TRIANGLE);
        setint(lua, "circle", PSP2_CTRL_CIRCLE);
        setint(lua, "cross", PSP2_CTRL_CROSS);
        setint(lua, "square", PSP2_CTRL_SQUARE);
        setint(lua, "any", PSP2_CTRL_ANY);
	lua_setglobal(lua, "button");
}
#endif
