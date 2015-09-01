#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/power.h>

void ffi_register_battery()
{
	static Function funcs[] =
	{
		{"scePowerIsBatteryCharging", scePowerIsBatteryCharging},
		{"scePowerGetBatteryLifePercent", scePowerGetBatteryLifePercent},
		{"scePowerIsPowerOnline", scePowerIsPowerOnline},
		{"scePowerGetBatteryLifeTime", scePowerGetBatteryLifeTime},
		{"scePowerGetBatteryRemainCapacity", scePowerGetBatteryRemainCapacity},
		{"scePowerIsLowBattery", scePowerIsLowBattery},
		{"scePowerGetBatteryFullCapacity", scePowerGetBatteryFullCapacity},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
