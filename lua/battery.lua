-- battery
local ffi = require 'ffi'

ffi.cdef [[
int scePowerIsBatteryCharging();
int scePowerGetBatteryLifePercent();
int scePowerIsPowerOnline();
int scePowerGetBatteryLifeTime();
int scePowerGetBatteryRemainCapacity(); //?
int scePowerIsLowBattery();
int scePowerGetBatteryFullCapacity(); //?
]]

battery = {}

function battery.is_charging()
  -- return ffi.C.scePowerIsBatteryCharging() == 1
  return battery.has_charger() and battery.get_percent() ~= 100
end

function battery.get_percent()
  return ffi.C.scePowerGetBatteryLifePercent()
end

function battery.has_charger()
  return ffi.C.scePowerIsPowerOnline() == 1
end

--[[
-- unresolved syscalls

 function battery.get_remaining_capacity()
  return ffi.C.scePowerGetBatteryRemainCapacity()
end

function battery.is_low()
  return ffi.C.scePowerIsLowBattery() == 1
end

function battery.get_full_capacity()
  return ffi.C.scePowerGetBatteryFullCapacity()
end

function battery.get_remaining_time()
  return ffi.C.scePowerGetBatteryLifeTime()
end
]]
