#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/kernel/threadmgr.h>
#include <psp2/kernel/processmgr.h>
#include <zlib.h>
#include <stdlib.h>

void ffi_register_misc()
{
	static Function funcs[] =
	{
		{"sceKernelDelayThread", sceKernelDelayThread},
		{"sceKernelGetProcessTime", sceKernelGetProcessTime},
		{"sceKernelExitProcess", sceKernelExitProcess},
		{"crc32", crc32},
		{"malloc", malloc},
		{"free", free},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
