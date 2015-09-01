#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/io/dirent.h>

void ffi_register_fs()
{
	static Function funcs[] =
	{
		{"sceIoDopen", sceIoDopen},
		{"sceIoDread", sceIoDread},
		{"sceIoDclose", sceIoDclose},
		{"sceIoMkdir", sceIoMkdir},
		{"sceIoRmdir", sceIoRmdir},
		{"sceIoGetstat", sceIoGetstat},
		{"sceIoChstat", sceIoChstat},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
