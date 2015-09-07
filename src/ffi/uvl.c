#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/uvl.h>

void ffi_register_uvl()
{
	static Function funcs[] =
	{
		{"uvl_alloc_code_mem", uvl_alloc_code_mem},
		{"uvl_unlock_mem", uvl_unlock_mem},
		{"uvl_lock_mem", uvl_lock_mem},
		{"uvl_flush_icache", uvl_flush_icache},
		{"uvl_load", uvl_load},
		{"uvl_exit", uvl_exit},
		{"uvl_log_write", uvl_log_write},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
