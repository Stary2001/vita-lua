#include <stddef.h>
#include <stub_ffi.h>
#include <vita2d.h>

void ffi_register_vita2d()
{
	static Function funcs[] =
	{
		{"vita2d_init", vita2d_init},
		{"vita2d_init_advanced", vita2d_init_advanced},
		{"vita2d_fini", vita2d_fini},
		{"vita2d_clear_screen", vita2d_clear_screen},
		{"vita2d_swap_buffers", vita2d_swap_buffers},
		{"vita2d_start_drawing", vita2d_start_drawing},
		{"vita2d_end_drawing", vita2d_end_drawing},
		{"vita2d_set_clear_color", vita2d_set_clear_color},
		{"vita2d_set_vblank_wait", vita2d_set_vblank_wait},
		{"vita2d_get_current_fb", vita2d_get_current_fb},
		{"vita2d_pool_malloc", vita2d_pool_malloc},
		{"vita2d_pool_memalign", vita2d_pool_memalign},
		{"vita2d_pool_free_space", vita2d_pool_free_space},
		{"vita2d_pool_reset", vita2d_pool_reset},
		{"vita2d_draw_pixel", vita2d_draw_pixel},
		{"vita2d_draw_line", vita2d_draw_line},
		{"vita2d_draw_rectangle", vita2d_draw_rectangle},
		{"vita2d_draw_fill_circle", vita2d_draw_fill_circle},
		{"vita2d_create_empty_texture", vita2d_create_empty_texture},
		{"vita2d_create_empty_texture_format", vita2d_create_empty_texture_format},
		{"vita2d_free_texture", vita2d_free_texture},
		{"vita2d_texture_get_width", vita2d_texture_get_width},
		{"vita2d_texture_get_height", vita2d_texture_get_height},
		{"vita2d_texture_get_stride", vita2d_texture_get_stride},
		{"vita2d_texture_get_format", vita2d_texture_get_format},
		{"vita2d_texture_get_datap", vita2d_texture_get_datap},
		{"vita2d_texture_get_palette", vita2d_texture_get_palette},
		{"vita2d_draw_texture", vita2d_draw_texture},
		{"vita2d_draw_texture_rotate", vita2d_draw_texture_rotate},
		{"vita2d_draw_texture_rotate_hotspot", vita2d_draw_texture_rotate_hotspot},
		{"vita2d_draw_texture_scale", vita2d_draw_texture_scale},
		{"vita2d_draw_texture_part", vita2d_draw_texture_part},
		{"vita2d_draw_texture_part_scale", vita2d_draw_texture_part_scale},
		{"vita2d_draw_texture_tint", vita2d_draw_texture_tint},
		{"vita2d_draw_texture_tint_rotate", vita2d_draw_texture_tint_rotate},
		{"vita2d_draw_texture_tint_rotate_hotspot", vita2d_draw_texture_tint_rotate_hotspot},
		{"vita2d_draw_texture_tint_scale", vita2d_draw_texture_tint_scale},
		{"vita2d_draw_texture_tint_part", vita2d_draw_texture_tint_part},
		{"vita2d_draw_texture_tint_part_scale", vita2d_draw_texture_tint_part_scale},
		{"vita2d_load_PNG_file", vita2d_load_PNG_file},
		{"vita2d_load_PNG_buffer", vita2d_load_PNG_buffer},
		{"vita2d_load_JPEG_file", vita2d_load_JPEG_file},
		{"vita2d_load_JPEG_buffer", vita2d_load_JPEG_buffer},
		{"vita2d_load_BMP_file", vita2d_load_BMP_file},
		{"vita2d_load_BMP_buffer", vita2d_load_BMP_buffer},
		{"vita2d_load_font_file", vita2d_load_font_file},
		{"vita2d_load_font_mem", vita2d_load_font_mem},
		{"vita2d_free_font", vita2d_free_font},
		{"vita2d_font_draw_text", vita2d_font_draw_text},
		{"vita2d_font_draw_textf", vita2d_font_draw_textf},
		{"vita2d_font_text_dimensions", vita2d_font_text_dimensions},
		{"vita2d_font_text_width", vita2d_font_text_width},
		{"vita2d_font_text_height", vita2d_font_text_height},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
