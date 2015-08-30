#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/touch.h>

void open_touch()
{
	static Function funcs[] =
	{
		{"sceTouchGetPanelInfo", sceTouchGetPanelInfo},
		{"sceTouchRead", sceTouchRead},
		{"sceTouchPeek", sceTouchPeek},
		{"sceTouchSetSamplingState", sceTouchSetSamplingState},
		{"sceTouchGetSamplingState", sceTouchGetSamplingState},
		{"sceTouchEnableTouchForce", sceTouchEnableTouchForce},
		{"sceTouchDisableTouchForce", sceTouchDisableTouchForce},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
