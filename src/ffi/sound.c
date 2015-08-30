#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/audioout.h>

void open_sound()
{
	static Function funcs[] =
	{
		{"sceAudioOutOpenPort", sceAudioOutOpenPort},
		{"sceAudioOutReleasePort", sceAudioOutReleasePort},
		{"sceAudioOutOutput", sceAudioOutOutput},
		{"sceAudioOutSetVolume", sceAudioOutSetVolume},
		{"sceAudioOutSetConfig", sceAudioOutSetConfig},
		{"sceAudioOutGetConfig", sceAudioOutGetConfig},
		{"sceAudioOutSetAlcMode", sceAudioOutSetAlcMode},
		{"sceAudioOutGetRestSample", sceAudioOutGetRestSample},
		{"sceAudioOutGetAdopt", sceAudioOutGetAdopt},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
