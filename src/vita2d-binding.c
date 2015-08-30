#ifndef JIT
#include <lua.h>
#include <lauxlib.h>

#include <vita2d.h>
#include <string.h>
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

int bind_vita2d_clear_screen(lua_State *l)
{
	vita2d_clear_screen();
	return 0;
}

int bind_vita2d_swap_buffers(lua_State *l)
{
        vita2d_swap_buffers();
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

int bind_vita2d_set_clear_color(lua_State *l)
{
	unsigned int c = (unsigned int)luaL_checkinteger(l, 1);
	vita2d_set_clear_color(c);
	return 0;
}

int bind_vita2d_set_vblank_wait(lua_State *l)
{
	int enable = lua_toboolean(l, 1);
	vita2d_set_vblank_wait(enable);
	return 0;
}

int bind_vita2d_draw_pixel(lua_State *l)
{
	float x = luaL_checknumber(l, 1);
	float y = luaL_checknumber(l, 2);
	unsigned int color = (unsigned int) luaL_checkinteger(l, 3);
	vita2d_draw_pixel(x, y, color);
	return 0;
}

int bind_vita2d_draw_line(lua_State *l)
{
	float x0 = luaL_checknumber(l, 1);
	float y0 = luaL_checknumber(l, 2);
	float x1 = luaL_checknumber(l, 3);
	float y1 = luaL_checknumber(l, 4);
	unsigned int color = (unsigned int)luaL_checkinteger(l, 5);
	vita2d_draw_line(x0, y0, x1, y1, color);
	return 0;
}

int bind_vita2d_draw_rectangle(lua_State *l)
{
	float x = luaL_checknumber(l, 1);
	float y = luaL_checknumber(l, 2);
	float w = luaL_checknumber(l, 3);
	float h = luaL_checknumber(l, 4);
	unsigned int color = (unsigned int)luaL_checkinteger(l, 5); 
	vita2d_draw_rectangle(x, y, w, h, color);
	return 0;
}

int bind_vita2d_draw_circle(lua_State *l)
{
	float x = luaL_checknumber(l, 1);
	float y = luaL_checknumber(l, 2);
	float r = luaL_checknumber(l, 3);
	unsigned int color = (unsigned int)luaL_checkinteger(l, 4);
	vita2d_draw_fill_circle(x, y, r, color);
	return 0;
}

void push_texture(lua_State *l, vita2d_texture *tex)
{
	vita2d_texture **v = lua_newuserdata(l,sizeof(vita2d_texture*));
	*v = tex;
	luaL_getmetatable(l, "vita2d_texture");
	lua_setmetatable(l, -2);
}

void push_font(lua_State *l, vita2d_font *f)
{
        vita2d_font **v = lua_newuserdata(l,sizeof(vita2d_font*));
        *v = f;
        luaL_getmetatable(l, "vita2d_font");
	lua_setmetatable(l, -2);
}

int bind_vita2d_create_empty_texture(lua_State *l)
{
	int w = luaL_checkinteger(l, 1);
	int h = luaL_checkinteger(l, 2);

	vita2d_texture *tex = vita2d_create_empty_texture(w, h);
	if(tex != NULL)
	{
		push_texture(l, tex);
	}
	else
	{
		lua_pushnil(l);
	}
	return 1;
}

int bind_vita2d_create_empty_texture_format(lua_State *l)
{
	int w = luaL_checkinteger(l, 1);
	int h = luaL_checkinteger(l, 2);
	int format = luaL_checkinteger(l, 3);

        vita2d_texture *tex = vita2d_create_empty_texture_format(w, h, format);
        if(tex != NULL)
        {
		push_texture(l, tex);
        }
        else
        {
                lua_pushnil(l);
        }
        return 1;
}

int bind_vita2d_free_texture(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	vita2d_free_texture(*tex);
	return 0;
}

int bind_vita2d_texture_get_width(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	lua_pushinteger(l, vita2d_texture_get_width(*tex));
	return 1;
}

int bind_vita2d_texture_get_height(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	lua_pushinteger(l, vita2d_texture_get_height(*tex));
	return 1;
}

int bind_vita2d_texture_get_stride(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	lua_pushinteger(l, vita2d_texture_get_stride(*tex));
	return 1;
}

int bind_vita2d_texture_get_format(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	lua_pushinteger(l, vita2d_texture_get_format(*tex));
	return 1;
}

/* todo: implement Buffer
void *vita2d_texture_get_datap(const vita2d_texture *texture);
void *vita2d_texture_get_palette(const vita2d_texture *texture);
*/

int bind_vita2d_draw_texture(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	float x = luaL_checknumber(l, 2);
	float y = luaL_checknumber(l, 3);
	vita2d_draw_texture(*tex, x, y);
	return 0;
}

int bind_vita2d_draw_texture_rotate(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	float x = luaL_checknumber(l, 2);
	float y = luaL_checknumber(l, 3);
	float r = luaL_checknumber(l, 4);
	vita2d_draw_texture_rotate(*tex, x, y, r);
	return 0;
}

int bind_vita2d_draw_texture_rotate_hotspot(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	float x = luaL_checknumber(l, 2); 
	float y = luaL_checknumber(l, 3);
	float r = luaL_checknumber(l, 4);
	float cx = luaL_checknumber(l, 5);
	float cy = luaL_checknumber(l, 6);
	vita2d_draw_texture_rotate_hotspot(*tex, x, y, r, cx, cy);
	return 0;
}

int bind_vita2d_draw_texture_scale(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	float x = luaL_checknumber(l, 2);
	float y = luaL_checknumber(l, 3);
	float xs = luaL_checknumber(l, 4);
	float ys = luaL_checknumber(l, 5);
	vita2d_draw_texture_scale(*tex, x, y, xs, ys);
	return 0;
}

int bind_vita2d_draw_texture_part(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	float x = luaL_checknumber(l, 2);
	float y = luaL_checknumber(l, 3);
	float t_x = luaL_checknumber(l, 4);
	float t_y = luaL_checknumber(l, 5);
	float t_w = luaL_checknumber(l, 6);
	float t_h = luaL_checknumber(l, 7);
	vita2d_draw_texture_part(*tex, x, y, t_x, t_y, t_w, t_h);
	return 0;
}

int bind_vita2d_draw_texture_part_scale(lua_State *l)
{
	vita2d_texture **tex = (vita2d_texture**) luaL_checkudata(l, 1, "vita2d_texture");
	float x = luaL_checknumber(l, 2);
	float y = luaL_checknumber(l, 3);
	float t_x = luaL_checknumber(l, 4);
	float t_y = luaL_checknumber(l, 5);
	float t_w = luaL_checknumber(l, 6);
	float t_h = luaL_checknumber(l, 7);
	float x_s = luaL_checknumber(l, 8);
	float y_s = luaL_checknumber(l, 9);
	
	vita2d_draw_texture_part_scale(*tex, x, y, t_x, t_y, t_w, t_h, x_s, y_s);
	return 0;
}

/*
void vita2d_draw_texture_tint(const vita2d_texture *texture, float x, float y, unsigned int color);
void vita2d_draw_texture_tint_rotate(const vita2d_texture *texture, float x, float y, float rad, unsigned int color);
void vita2d_draw_texture_tint_rotate_hotspot(const vita2d_texture *texture, float x, float y, float rad, float center_x, float center_y, unsigned int color);
void vita2d_draw_texture_tint_scale(const vita2d_texture *texture, float x, float y, float x_scale, float y_scale, unsigned int color);
void vita2d_draw_texture_tint_part(const vita2d_texture *texture, float x, float y, float tex_x, float tex_y, float tex_w, float tex_h, unsigned int color);
void vita2d_draw_texture_tint_part_scale(const vita2d_texture *texture, float x, float y, float tex_x, float tex_y, float tex_w, float tex_h, float x_scale, float y_scale, unsigned int color);
*/

int bind_vita2d_load_texture(lua_State *l)
{
	const char *f = luaL_checkstring(l, 1);
	const char *ext = f + strlen(f) - 4;
	debugNetPrintf(DEBUG, "strcmp 1 %s\n", f);
	debugNetPrintf(DEBUG, "%s\n", ext);
	vita2d_texture *tex = NULL;
	
	if(strcmp(ext, ".png") == 0)
	{
		debugNetPrintf(DEBUG, "load png\n");
		tex = vita2d_load_PNG_file(f);
	}
	else if(strcmp(ext, ".bmp") == 0)
	{
		debugNetPrintf(DEBUG, "load bmp\n");
		tex = vita2d_load_BMP_file(f);
	}
	else if(strcmp(ext, ".jpg") == 0 || strcmp(ext, "jpeg") == 0)
	{
		debugNetPrintf(DEBUG, "load jpeg\n");
		tex = vita2d_load_JPEG_file(f);
	}
	debugNetPrintf(DEBUG, "loaded\n");
	if(tex != NULL)
	{
		push_texture(l, tex);
	}
	else
	{
		lua_pushnil(l);
	}
	return 1;
}

int bind_vita2d_load_font_file(lua_State *l)
{
	vita2d_font *f = vita2d_load_font_file(luaL_checkstring(l, 1));
	if(f != NULL)
	{
		push_font(l, f);
	}
	else
	{
		lua_pushnil(l);
	}

	return 1;
}

int bind_vita2d_free_font(lua_State *l)
{
	vita2d_font **f = luaL_checkudata(l, 1, "vita2d_font");
	vita2d_free_font(*f);
	return 0;
}

int bind_vita2d_draw_text(lua_State *l)
{
	vita2d_font *f = *(vita2d_font**)lua_touserdata(l, 1);
	int x = luaL_checkinteger(l, 2);
	int y = luaL_checkinteger(l, 3);
	unsigned int color = (unsigned int)luaL_checkinteger(l, 4);
	int size = luaL_checkinteger(l, 5);
	const char *text = luaL_checkstring(l, 6);
	vita2d_font_draw_text(f, x, y, color, size, text);
	return 0;
}

/*
void vita2d_font_draw_textf(vita2d_font *font, int x, int y, unsigned int color, unsigned int size, const char *text, ...);
void vita2d_font_text_dimensions(vita2d_font *font, unsigned int size, const char *text, int *width, int *height);
int vita2d_font_text_width(vita2d_font *font, unsigned int size, const char *text);
int vita2d_font_text_height(vita2d_font *font, unsigned int size, const char *text);
*/

const luaL_Reg vita2d[] =
{
	{"init", bind_vita2d_init},
	{"fini", bind_vita2d_fini},
	{"load_font_file", bind_vita2d_load_font_file},
	{"draw_text", bind_vita2d_draw_text},
	{"start_drawing", bind_vita2d_start_drawing},
	{"end_drawing", bind_vita2d_end_drawing},
	{"clear_screen", bind_vita2d_clear_screen},
	{"swap_buffers", bind_vita2d_swap_buffers},
	{"set_clear_color", bind_vita2d_set_clear_color},
	{"set_vblank_wait", bind_vita2d_set_vblank_wait},
	{"draw_pixel", bind_vita2d_draw_pixel},
	{"draw_line", bind_vita2d_draw_line},
	{"draw_rectangle", bind_vita2d_draw_rectangle},	
	{"draw_circle", bind_vita2d_draw_circle},
	{"create_empty_texture", bind_vita2d_create_empty_texture},
	{"create_empty_texture_format", bind_vita2d_create_empty_texture_format},
	{"free_texture", bind_vita2d_free_texture},
	{"draw_texture", bind_vita2d_draw_texture},
	{"draw_texture_rotate", bind_vita2d_draw_texture_rotate},
	{"draw_texture_rotate_hotspot", bind_vita2d_draw_texture_rotate_hotspot},
	{"draw_texture_scale", bind_vita2d_draw_texture_scale},
	{"draw_texture_part", bind_vita2d_draw_texture_part},
	{"draw_texture_part_scale", bind_vita2d_draw_texture_part_scale },
	{"load_texture", bind_vita2d_load_texture},
	{NULL, NULL}
};

const luaL_Reg vita2d_texture_funcs[] =
{
	{"get_width", bind_vita2d_texture_get_width},
	{"get_height", bind_vita2d_texture_get_height},
	{"get_stride", bind_vita2d_texture_get_stride},
	{"get_format", bind_vita2d_texture_get_format},
	{NULL,NULL}
};

void open_vita2d(lua_State *lua)
{
#ifdef JIT
	luaL_register(lua, "vita2d", vita2d);
#else
	luaL_newlib(lua, vita2d);
	lua_setglobal(lua, "vita2d");
#endif
	luaL_newmetatable(lua, "vita2d_texture");
#ifdef JIT
        luaL_register(lua, NULL, vita2d_texture_funcs);
#else
	luaL_newlib(lua, vita2d_texture_funcs);
#endif
	lua_pushliteral(lua, "__index");
	lua_pushvalue(lua, -2);
	lua_rawset(lua, -3); // __index = methods
	lua_pushliteral(lua, "__metatable");
	lua_pushvalue(lua, -2);
	lua_rawset(lua, -3);
	lua_pop(lua, 1); // pop metatable

	luaL_newmetatable(lua, "vita2d_font");
	lua_pop(lua, 1);
}

#endif
