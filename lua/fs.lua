-- fs
local ffi = require 'ffi'

ffi.cdef [[

typedef struct SceDateTime {
    unsigned short year;
    unsigned short month;
    unsigned short day;
    unsigned short hour;
    unsigned short minute;
    unsigned short second;
    unsigned int microsecond;
} SceDateTime;
typedef int64_t SceInt64;
typedef int SceUID;
typedef int SceMode; 
typedef SceInt64 SceOff;

enum {
        /** Format bits mask */
        PSP2_S_IFMT             = 0xF000,
        /** Symbolic link */
        PSP2_S_IFLNK            = 0x4000,
        /** Directory */
        PSP2_S_IFDIR            = 0x1000,
        /** Regular file */
        PSP2_S_IFREG            = 0x2000,

        /** Set UID */
        PSP2_S_ISUID            = 0x0800,
        /** Set GID */
        PSP2_S_ISGID            = 0x0400,
        /** Sticky */
        PSP2_S_ISVTX            = 0x0200,

        /** User access rights mask */
        PSP2_S_IRWXU            = 0x01C0,
        /** Read user permission */
        PSP2_S_IRUSR            = 0x0100,
        /** Write user permission */
        PSP2_S_IWUSR            = 0x0080,
        /** Execute user permission */
        PSP2_S_IXUSR            = 0x0040,

        /** Group access rights mask */
        PSP2_S_IRWXG            = 0x0038,
        /** Group read permission */
        PSP2_S_IRGRP            = 0x0020,
        /** Group write permission */
        PSP2_S_IWGRP            = 0x0010,
        /** Group execute permission */
        PSP2_S_IXGRP            = 0x0008,

        /** Others access rights mask */
        PSP2_S_IRWXO            = 0x0007,
        /** Others read permission */
        PSP2_S_IROTH            = 0x0004,
        /** Others write permission */
        PSP2_S_IWOTH            = 0x0002,
        /** Others execute permission */
        PSP2_S_IXOTH            = 0x0001,
};

enum {
        /** Format mask */
        PSP2_SO_IFMT             = 0x0038,               // Format mask
        /** Symlink */
        PSP2_SO_IFLNK            = 0x0008,               // Symbolic link
        /** Directory */
        PSP2_SO_IFDIR            = 0x0010,               // Directory
        /** Regular file */
        PSP2_SO_IFREG            = 0x0020,               // Regular file

        /** Hidden read permission */
        PSP2_SO_IROTH            = 0x0004,               // read
        /** Hidden write permission */
        PSP2_SO_IWOTH            = 0x0002,               // write
        /** Hidden execute permission */
        PSP2_SO_IXOTH            = 0x0001,               // execute
};

/** Structure to hold the status information about a file */
typedef struct SceIoStat {
        SceMode st_mode;
        unsigned int    st_attr;
        /** Size of the file in bytes. */
        SceOff  st_size;
        /** Creation time. */
        SceDateTime     st_ctime;
        /** Access time. */
        SceDateTime     st_atime;
        /** Modification time. */
        SceDateTime     st_mtime;
        /** Device-specific data. */
        unsigned int    st_private[6];
} SceIoStat;

typedef struct SceIoDirent {
        /** File status. */
        SceIoStat       d_stat;
        /** File name. */
        char    d_name[256];
        /** Device-specific data. */
        void    *d_private;
        int     dummy;
} SceIoDirent;

SceUID sceIoDopen(const char *dirname);
int sceIoDread(SceUID fd, SceIoDirent *dir);
int sceIoDclose(SceUID fd);
int sceIoMkdir(const char *dir, SceMode mode);
int sceIoRmdir(const char *path);
// int sceIoChdir(const char *path);
]]

fs = {}
fs.working_dir = "cache0:/VitaDefilerClient/Documents"

function fs.list(path)
  t = {}

  fd = ffi.C.sceIoDopen(path)
  if d < 0 then return end
  dirent = ffi.new("SceIoDirent[1]")
  while ffi.C.ioDread(fd, dirent) do
    t[#t + 1] = { name = dirent.d_name, directory = (bit.band(dirent.d_stat.st_attr, ffi.C.PSP2_S_IFDIR) ~= 0), size = tonumber(dirent.st_size) }
  end
  return t
end

function fs.mkdir(path)
  ffi.C.sceIoMkdir(path, bit.bor(ffi.C.PSP2_S_IRWXU, ffi.C.PSP2_S_IRWXG, ffi.C.PSP2_S_IXOTH)) -- all the permissions!
end

function fs.rmdir(path)
  ffi.C.sceIoRmdir(path)
end

function fs.chdir(path)
  if path == nil then 
    return fs.working_dir
  end

  local tmp = fs.working_dir
  fs.working_dir = path
  return tmp
end 

function fs.is_relative(path)
  return not path:find("^(.-):")
end

local orig_io = io
io = {}
setmetatable(io, { __index = orig_io })

function io.open(name, mode)
  if fs.is_relative(name) then
    name = fs.working_dir .. "/" .. name
  end
  return orig_io.open(name, mode)
end

local orig_dofile = dofile
local orig_loadfile = loadfile

function dofile(path)
  if fs.is_relative(path) then
    path = fs.working_dir .. "/" .. path
  end
  orig_dofile(path)
end

function loadfile(path)
  if fs.is_relative(path) then
    path = fs.working_dir .. "/" .. path
  end
  return orig_loadfile(path)
end
