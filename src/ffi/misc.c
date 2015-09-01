#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/kernel/threadmgr.h>
#include <psp2/kernel/processmgr.h>

void ffi_register_misc()
{
	static Function funcs[] =
	{
		{"sceKernelDelayThread", sceKernelDelayThread},
		{"sceKernelGetProcessTime", sceKernelGetProcessTime},
		{"sceKernelExitProcess", sceKernelExitProcess},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
