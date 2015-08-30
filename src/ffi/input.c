#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/ctrl.h>

void ffi_register_input()
{
	static Function funcs[] =
	{
		{"sceCtrlSetSamplingMode", sceCtrlSetSamplingMode},
		{"sceCtrlGetSamplingMode", sceCtrlGetSamplingMode},
		{"sceCtrlPeekBufferPositive", sceCtrlPeekBufferPositive},
		{"sceCtrlPeekBufferNegative", sceCtrlPeekBufferNegative},
		{"sceCtrlReadBufferPositive", sceCtrlReadBufferPositive},
		{"sceCtrlReadBufferNegative", sceCtrlReadBufferNegative},
		{"sceCtrlSetRapidFire", sceCtrlSetRapidFire},
		{"sceCtrlClearRapidFire", sceCtrlClearRapidFire},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
