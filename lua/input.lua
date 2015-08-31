local bit = require 'bit'
local ffi = require 'ffi'

ffi.cdef [[
typedef uint8_t SceUInt8;
typedef int16_t SceInt16;
typedef uint16_t SceUInt16;
typedef uint32_t SceUInt32;
typedef uint64_t SceUInt64;

enum {
        PSP2_CTRL_SELECT        = 0x000001,     //!< Select button.
        PSP2_CTRL_START         = 0x000008,     //!< Start button.
        PSP2_CTRL_UP            = 0x000010,     //!< Up D-Pad button.
        PSP2_CTRL_RIGHT         = 0x000020,     //!< Right D-Pad button.
        PSP2_CTRL_DOWN          = 0x000040,     //!< Down D-Pad button.
        PSP2_CTRL_LEFT          = 0x000080,     //!< Left D-Pad button.
        PSP2_CTRL_LTRIGGER      = 0x000100,     //!< Left trigger.
        PSP2_CTRL_RTRIGGER      = 0x000200,     //!< Right trigger.
        PSP2_CTRL_TRIANGLE      = 0x001000,     //!< Triangle button.
        PSP2_CTRL_CIRCLE        = 0x002000,     //!< Circle button.
        PSP2_CTRL_CROSS         = 0x004000,     //!< Cross button.
        PSP2_CTRL_SQUARE        = 0x008000,     //!< Square button.
        PSP2_CTRL_ANY           = 0x010000      //!< Any input intercepted.
};

enum {
        /** Digitial buttons only. */
        PSP2_CTRL_MODE_DIGITAL = 0,
        /** Digital buttons + Analog support. */
        PSP2_CTRL_MODE_ANALOG,
        /** Same as ::PSP2_CTRL_MODE_ANALOG, but with larger range for analog sticks. */
        PSP2_CTRL_MODE_ANALOG_WIDE
};

/** Returned controller data */
typedef struct SceCtrlData {
        /** The current read frame. */
        uint64_t        timeStamp;
        /** Bit mask containing zero or more of ::CtrlButtons. */
        unsigned int    buttons;
        /** Left analogue stick, X axis. */
        unsigned char   lx;
        /** Left analogue stick, Y axis. */
        unsigned char   ly;
        /** Right analogue stick, X axis. */
        unsigned char   rx;
        /** Right analogue stick, Y axis. */
        unsigned char   ry;
        /** Reserved. */
        uint8_t         reserved[16];
} SceCtrlData;

typedef struct SceCtrlRapidFireRule {
        unsigned int Mask;
        unsigned int Trigger;
        unsigned int Target;
        unsigned int Delay;
        unsigned int Make;
        unsigned int Break;
} SceCtrlRapidFireRule;

int sceCtrlSetSamplingMode(int mode);
int sceCtrlGetSamplingMode(int *pMode);
int sceCtrlPeekBufferPositive(int port, SceCtrlData *pad_data, int count);
int sceCtrlPeekBufferNegative(int port, SceCtrlData *pad_data, int count);
int sceCtrlReadBufferPositive(int port, SceCtrlData *pad_data, int count);
int sceCtrlReadBufferNegative(int port, SceCtrlData *pad_data, int count);
int sceCtrlSetRapidFire(int port, int idx, const SceCtrlRapidFireRule* pRule);
int sceCtrlClearRapidFire(int port, int idx);
]]

input = {}
buttons = {
  ["select"] = ffi.C.PSP2_CTRL_SELECT,
  ["start"] = ffi.C.PSP2_CTRL_START,
  ["up"] = ffi.C.PSP2_CTRL_UP,
  ["right"] = ffi.C.PSP2_CTRL_RIGHT,
  ["down"] = ffi.C.PSP2_CTRL_DOWN,
  ["left"] = ffi.C.PSP2_CTRL_LEFT,
  ["l_trigger"] = ffi.C.PSP2_CTRL_LTRIGGER,
  ["r_trigger"] = ffi.C.PSP2_CTRL_RTRIGGER,
  ["triangle"] = ffi.C.PSP2_CTRL_TRIANGLE,
  ["circle"] = ffi.C.PSP2_CTRL_CIRCLE,
  ["cross"] = ffi.C.PSP2_CTRL_CROSS,
  ["square"] = ffi.C.PSP2_CTRL_SQUARE,
  ["any"] = ffi.C.PSP2_CTRL_ANY
}


function input.set_mode(mode)
  if mode == "digital" then
    mode = ffi.C.PSP2_CTRL_MODE_DIGITAL
  elseif mode == "analog" then
    mode = ffi.C.PSP2_CTRL_MODE_ANALOG
  elseif mode == "analog_wide" then
    mode = PSP2_CTRL_MODE_ANALOG_WIDE
  else
    error("Invalid input mode!")
  end
  ffi.C.sceCtrlGetSamplingMode(mode)
end

function input.get_mode()
  mode = ffi.new("SceUint32[1]")
  ffi.C.sceCtrlGetSamplingMode(mode)
  mode = mode[0]
  if mode == ffi.C.PSP2_CTRL_MODE_DIGITAL then
    mode = "digital"
  elseif mode == ffi.C.PSP2_CTRL_MODE_ANALOG then
    mode = "analog"
  elseif mode == ffi.C.PSP2_CTRL_MODE_ANALOG_WIDE then
    mode = "analog_wide"
  end
  return mode
end

function input.peek(mode)
  if mode == nil then mode = "positive" end
  pad = ffi.new("SceCtrlData[1]")
  if mode == "positive" then
    ffi.C.sceCtrlPeekBufferPositive(0, pad, 1)
  elseif mode == "negative" then
    ffi.C.sceCtrlPeekBufferNegative(0, pad, 1)
  end
  return pad[0]
end

function input.read(mode)
  if mode == nil then mode = "positive" end
  pad = ffi.new("SceCtrlData[1]")
  if mode == "positive" then
    ffi.C.sceCtrlReadBufferPositive(0, pad, 1)
  elseif mode == "negative" then
    ffi.C.sceCtrlReadBufferNegative(0, pad, 1)
  end
  return pad[0]
end

function input.is_pressed(button)
  pad = input.peek()
  if bit.band(button, pad.buttons) ~= 0 then
    return true
  else return false end
end
