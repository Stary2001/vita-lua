#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/kernel/threadmgr.h>

void ffi_register_misc()
{
	static Function funcs[] =
	{
		{"sceKernelDelayThread", sceKernelDelayThread},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
