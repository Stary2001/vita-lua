-- audio
local ffi = require 'ffi'

ffi.cdef [[
enum {
        //! Used for main audio output, freq must be set to 48000 Hz
        PSP2_AUDIO_OUT_PORT_TYPE_MAIN   = 0,

        //! Used for Background Music port
        PSP2_AUDIO_OUT_PORT_TYPE_BGM    = 1,

        //! Used for voice chat port
        PSP2_AUDIO_OUT_PORT_TYPE_VOICE  = 2
};

/*const int PSP2_AUDIO_MIN_LEN = 64;
const int PSP2_AUDIO_MAX_LEN = 65472;        //!< Maximum granularity*/

int sceAudioOutOpenPort(int type, int len, int freq, int mode);
int sceAudioOutReleasePort(int port);
int sceAudioOutOutput(int port, const void *buf);

/*const int PSP2_AUDIO_OUT_MAX_VOL = 32768;                                    //!< Maximum output port volume
const int PSP2_AUDIO_VOLUME_0DB = PSP2_AUDIO_OUT_MAX_VOL;  //!< Maximum output port volume */

enum {
        PSP2_AUDIO_VOLUME_FLAG_L_CH     = 0x1, //!< Left Channel
        PSP2_AUDIO_VOLUME_FLAG_R_CH     = 0x2  //!< Right Channel
};

enum {
        PSP2_AUDIO_OUT_MODE_MONO        = 0,
        PSP2_AUDIO_OUT_MODE_STEREO      = 1
};

int sceAudioOutSetVolume(int port, int ch, int *vol);
int sceAudioOutSetConfig(int port, int len, int freq, int mode);

enum {
        PSP2_AUDIO_OUT_CONFIG_TYPE_LEN  = 0,
        PSP2_AUDIO_OUT_CONFIG_TYPE_FREQ = 1,
        PSP2_AUDIO_OUT_CONFIG_TYPE_MODE = 2
};

int sceAudioOutGetConfig(int port, int type);
int sceAudioOutGetRestSample(int port);
int sceAudioOutGetAdopt(int type);

]]

local function get_port(port)
  if port == "main" then
    return ffi.C.PSP2_AUDIO_OUT_PORT_TYPE_MAIN
  elseif port == "bgm" then
    return ffi.C.PSP2_AUDIO_OUT_PORT_TYPE_BGM
  elseif port == "voice" then
    return ffi.C.PSP2_AUDIO_OUT_PORT_TYPE_VOICE
  else
    error("Invalid audio port name!")
  end
end

local function get_mode(mode)
  if mode == "mono" then
    return ffi.C.PSP2_AUDIO_OUT_MODE_MONO
  elseif mode == "stereo" then
    return ffi.C.PSP2_AUDIO_OUT_MODE_STEREO
  else
    error("Invalid audio port mode!")
  end
end

audio = {}

function audio.open(port, len, freq, mode)
  if port == "main" then
    freq = 48000
  end
  port = get_port(port)
  mode = get_mode(mode)
  return ffi.C.sceAudioOutOpenPort(port, len, freq, mode)
end

function audio.release(port)
  ffi.C.sceAudioOutReleasePort(port)
end

function audio.play(port, samples) -- SAMPLES SHOULD BE A FFI BUFFER
  ffi.C.sceAudioOutOutput(port, samples)
end

function audio.set_volume(port, vol)
  v = ffi.new("int[2]", vol, vol)
  ffi.C.sceAudioOutSetVolume(port, bit.bor(1,2), v) -- l/r channels
end

function audio.set_config(port, len, freq, mode)
  mode = get_mode(mode)
  ffi.C.sceAudioOutSetConfig(port, len, freq, mode)
end

function audio.get_config(port, t)
  t = get_type(t)
  return ffi.C.sceAudioOutGetConfig(port, type)
end

function audio.get_remaining(port)
  return ffi.C.sceAudioOutGetRestSample(port)
end

function audio.is_open(port)
  port = get_port(port)
  return ffi.C.sceAudioOutGetAdopt(port) == 1
end

function audio.set_alc(mode)
  if mode == "max" then
    mode = ffi.C.PSP2_AUDIO_ALC_MODE_MAX
  elseif mode == "on" then
    mode = ffi.C.PSP2_AUDIO_ALC_MODE1
  elseif mode == "off" then
    mode = ffi.C.PSP2_AUDIO_ALC_OFF
  else
    error("Invalid ALC mode!")
  end
  ffi.C.sceAudioOutSetAlcMode(mode)
end
