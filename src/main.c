/* vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab : */

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
#include <vita2d.h>
#include <psp2/ctrl.h>

// Debugnet stuff
#ifdef DEBUGGER_IP
#include <debugnet.h>
#define debugf(...) \
    debugNetPrintf(DEBUG, "%s:%d %s: ", __FILE__, __LINE__, __func__); \
    debugNetPrintf(DEBUG, __VA_ARGS__)
#else
#define debugf(...) \
    printf("%s:%d %s: ", __FILE__, __LINE__, __func__); \
    printf(__VA_ARGS__)
#endif

int panic(lua_State *l)
{
    debugf("Lua paniced with '%s!'\n", lua_tostring(l, -1));
    sceKernelExitProcess(0);
    return 0;
}

int print(lua_State *l)
{
    debugf("[Lua] %s\n", lua_tostring(l, -1));
    return 0;
}

void open_ffi(lua_State *l);

int main()
{
    lua_State *lua = luaL_newstate();
    lua_atpanic(lua, panic);

    // Net init
    sceSysmoduleLoadModule(SCE_SYSMODULE_NET);
    SceNetInitParam netInitParam;
    int size = 1024 * 512;
    netInitParam.memory = malloc(size);
    netInitParam.size = size;
    netInitParam.flags = 0;
    sceNetInit(&netInitParam);

    sceSysmoduleLoadModule(SCE_SYSMODULE_HTTP);
#ifdef DEBUGGER_IP
    debugNetInit(DEBUGGER_IP, DEBUGGER_PORT, DEBUG);
#endif
    sceHttpInit(1024 * 50);

    // Init libs
    debugf("Init libs....\n");
    debugf("vita2d...\n");
    vita2d_init();
    debugf("physfs\n");
    PHYSFS_init(NULL);
    debugf("lualibs\n");
    luaL_openlibs(lua);
    debugf("ffi\n");
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

    debugf("[Lua] Loading app0:/lib/init.lua ...\n");
    if(luaL_loadfile(lua, "app0:/lib/init.lua") == 0)
    {
        if(lua_pcall(lua, 0, 0, 0) != 0)
        {
            debugf("[Lua] init error: %s\n", lua_tostring(lua, -1));
            lua_pop(lua, 1);
        }
    }

    debugf("[Lua] Loading app0:/boot.lua ...\n");
    if(luaL_loadfile(lua, "app0:/boot.lua") == 0)
    {
        if(lua_pcall(lua, 0, 0, 0) != 0)
        {
            debugf("[Lua] bootscript err: %s\n", lua_tostring(lua, -1));
            lua_pop(lua, 1);
        }
    }
    else
    {
    debugf("[Lua] bootscript load err: %s\n", lua_tostring(lua, -1));
        lua_pop(lua, 1);
    }

    debugf("Deinit. Goodbye.\n");
    sceHttpTerm();
    PHYSFS_deinit();
    vita2d_fini();
    //vita2d_free_texture(tex);

    sceKernelExitProcess(0);
    return 0;
}
