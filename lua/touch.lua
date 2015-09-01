-- touch
local ffi = require 'ffi'

ffi.cdef [[
typedef uint8_t SceUInt8;
typedef int16_t SceInt16;
typedef uint16_t SceUInt16;
typedef uint32_t SceUInt32;
typedef uint64_t SceUInt64;

enum {
        SCE_TOUCH_PORT_FRONT    = 0,    //!< Front touch panel id
        SCE_TOUCH_PORT_BACK     = 1,    //!< Back touch panel id
        SCE_TOUCH_PORT_MAX_NUM  = 2     //!< Number of touch panels
};

enum {
        SCE_TOUCH_MAX_REPORT    = 8     //!< FIXME 6 on front | 4 on back
};

typedef struct SceTouchPanelInfo {
        SceInt16 minAaX;        //!< Min active area X position
        SceInt16 minAaY;        //!< Min active area Y position
        SceInt16 maxAaX;        //!< Max active area X position
        SceInt16 maxAaY;        //!< Max active area Y position
        SceInt16 minDispX;      //!< Min display X origin (top left)
        SceInt16 minDispY;      //!< Min display Y origin (top left)
        SceInt16 maxDispX;      //!< Max display X origin (bottom right)
        SceInt16 maxDispY;      //!< Max display Y origin (bottom right)
        SceUInt8 minForce;      //!< Min touch force value
        SceUInt8 maxForce;      //!< Max touch force value
        SceUInt8 reserved[30];  //!< Reserved
} SceTouchPanelInfo;

typedef struct SceTouchReport {
        SceUInt8        id;             //!< Touch ID
        SceUInt8        force;          //!< Touch force
        SceInt16        x;              //!< X position
        SceInt16        y;              //!< Y position
        SceUInt8        reserved[8];    //!< Reserved
        SceUInt16       info;           //!< Information of this touch
} SceTouchReport;

typedef struct SceTouchData {
        SceUInt64       timeStamp;      //!< Data timestamp
        SceUInt32       status;         //!< Unused
        SceUInt32       reportNum;      //!< Number of touch reports
        SceTouchReport  report[SCE_TOUCH_MAX_REPORT];   //!< Touch reports
} SceTouchData;

int sceTouchGetPanelInfo(SceUInt32 port, SceTouchPanelInfo *pPanelInfo);
int sceTouchRead(SceUInt32 port, SceTouchData *pData, SceUInt32 nBufs);
int sceTouchPeek(SceUInt32 port, SceTouchData *pData, SceUInt32 nBufs);
int sceTouchSetSamplingState(SceUInt32 port, SceUInt32 state);
int sceTouchGetSamplingState(SceUInt32 port, SceUInt32 *pState);
int sceTouchEnableTouchForce(SceUInt32 port);
int sceTouchDisableTouchForce(SceUInt32 port);
]]

touch = {}

local function get_port(p)
  if p == "front" then
    return ffi.C.SCE_TOUCH_PORT_FRONT
  elseif p == "back" then
    return ffi.C.SCE_TOUCH_PORT_BACK
  else
    error("Invalid touch port!")
  end
end

function touch.get_info(port)
  port = get_port(port)
  info = ffi.new("SceTouchPanelInfo[1]")
  ffi.C.sceTouchGetPanelInfo(port, info)
  return info[0]
end

function touch.get_state(port)
  port = get_port(port)
  s = ffi.new("SceUInt32[1]")
  ffi.C.sceTouchGetSamplingState(port, s)
  return s[0]
end

function touch.set_state(port, active)
  port = get_port(port)
  active = active == 1 and true or false
  ffi.C.sceTouchSetSamplingState(port, active)
end

function touch.enable_force(port)
  port = get_port(port)
  ffi.C.sceTouchEnableTouchForce(port)
end

function touch.disable_force(port)
  port = get_port(port)
  ffi.C.sceTouchDisableTouchForce(port)
end

function touch.peek(port)
  port = get_port(port)
  local touch_data = ffi.new("SceTouchData[1]")
  ffi.C.sceTouchPeek(port, touch_data, 1)
  touch_data = touch_data[0]
  dat = {}
  for i = 0, touch_data.reportNum do
    dat[i + 1] = touch_data.reports[i]
  end
  return dat
end

function touch.read(port)
  port = get_port(port)
  local touch_data = ffi.new("SceTouchData[1]")
  ffi.C.sceTouchRead(port, touch_data, 1)
  touch_data = touch_data[0]
  return touch_data
end

function touch.is_pressed()
  return #touch.peek() ~= 0
end
