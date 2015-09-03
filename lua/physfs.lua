-- physfs
local ffi = require 'ffi'

ffi.cdef [[

typedef unsigned char         PHYSFS_uint8;
typedef signed char           PHYSFS_sint8;
typedef unsigned short        PHYSFS_uint16;
typedef signed short          PHYSFS_sint16;
typedef unsigned int          PHYSFS_uint32;
typedef signed int            PHYSFS_sint32;
typedef unsigned long long    PHYSFS_uint64;
typedef signed long long      PHYSFS_sint64;

typedef struct PHYSFS_File
{
    void *opaque;  /**< That's all you get. Don't touch. */
} PHYSFS_File;

typedef struct PHYSFS_ArchiveInfo
{
    const char *extension;   /**< Archive file extension: "ZIP", for example. */
    const char *description; /**< Human-readable archive description. */
    const char *author;      /**< Person who did support for this archive. */
    const char *url;         /**< URL related to this archive */
} PHYSFS_ArchiveInfo;

typedef struct PHYSFS_Version
{
    PHYSFS_uint8 major; /**< major revision */
    PHYSFS_uint8 minor; /**< minor revision */
    PHYSFS_uint8 patch; /**< patchlevel */
} PHYSFS_Version;

void PHYSFS_getLinkedVersion(PHYSFS_Version *ver);
int PHYSFS_init(const char *argv0);
int PHYSFS_deinit(void);
const PHYSFS_ArchiveInfo **PHYSFS_supportedArchiveTypes(void);
void PHYSFS_freeList(void *listVar);
const char *PHYSFS_getLastError(void);
const char *PHYSFS_getDirSeparator(void);
void PHYSFS_permitSymbolicLinks(int allow);
char **PHYSFS_getCdRomDirs(void);
const char *PHYSFS_getBaseDir(void);
// const char *PHYSFS_getUserDir(void); // this will probably crash
const char *PHYSFS_getWriteDir(void);
int PHYSFS_setWriteDir(const char *newDir);
// legacy calls
// int PHYSFS_addToSearchPath(const char *newDir, int appendToPath);
// int PHYSFS_removeFromSearchPath(const char *oldDir);
// char **PHYSFS_getSearchPath(void);
int PHYSFS_setSaneConfig(const char *organization, const char *appName, const char *archiveExt, int includeCdRoms, int archivesFirst); // who needs sane?
int PHYSFS_mkdir(const char *dirName);
int PHYSFS_delete(const char *filename);
const char *PHYSFS_getRealDir(const char *filename);
char **PHYSFS_enumerateFiles(const char *dir);
int PHYSFS_exists(const char *fname);
int PHYSFS_isDirectory(const char *fname);
int PHYSFS_isSymbolicLink(const char *fname);
PHYSFS_sint64 PHYSFS_getLastModTime(const char *filename);
PHYSFS_File *PHYSFS_openWrite(const char *filename);
PHYSFS_File *PHYSFS_openAppend(const char *filename);
PHYSFS_File *PHYSFS_openRead(const char *filename);
int PHYSFS_close(PHYSFS_File *handle);
PHYSFS_sint64 PHYSFS_read(PHYSFS_File *handle, void *buffer, PHYSFS_uint32 objSize, PHYSFS_uint32 objCount);
PHYSFS_sint64 PHYSFS_write(PHYSFS_File *handle, void *buffer, PHYSFS_uint32 objSize, PHYSFS_uint32 objCount);
int PHYSFS_eof(PHYSFS_File *handle);
PHYSFS_sint64 PHYSFS_tell(PHYSFS_File *handle);
int PHYSFS_seek(PHYSFS_File *handle, PHYSFS_uint64 pos);
PHYSFS_sint64 PHYSFS_fileLength(PHYSFS_File *handle);
int PHYSFS_setBuffer(PHYSFS_File *handle, PHYSFS_uint64 bufsize);
int PHYSFS_flush(PHYSFS_File *handle);
PHYSFS_sint16 PHYSFS_swapSLE16(PHYSFS_sint16 val);
PHYSFS_uint16 PHYSFS_swapULE16(PHYSFS_uint16 val);
PHYSFS_sint32 PHYSFS_swapSLE32(PHYSFS_sint32 val);
PHYSFS_uint32 PHYSFS_swapULE32(PHYSFS_uint32 val);
PHYSFS_sint64 PHYSFS_swapSLE64(PHYSFS_sint64 val);
PHYSFS_uint64 PHYSFS_swapULE64(PHYSFS_uint64 val);
PHYSFS_sint16 PHYSFS_swapSBE16(PHYSFS_sint16 val);
PHYSFS_uint16 PHYSFS_swapUBE16(PHYSFS_uint16 val);
PHYSFS_sint32 PHYSFS_swapSBE32(PHYSFS_sint32 val);
PHYSFS_uint32 PHYSFS_swapUBE32(PHYSFS_uint32 val);
PHYSFS_sint64 PHYSFS_swapSBE64(PHYSFS_sint64 val);
PHYSFS_uint64 PHYSFS_swapUBE64(PHYSFS_uint64 val);
int PHYSFS_readSLE16(PHYSFS_File *file, PHYSFS_sint16 *val);
int PHYSFS_readULE16(PHYSFS_File *file, PHYSFS_uint16 *val);
int PHYSFS_readSBE16(PHYSFS_File *file, PHYSFS_sint16 *val);
int PHYSFS_readUBE16(PHYSFS_File *file, PHYSFS_uint16 *val);
int PHYSFS_readSLE32(PHYSFS_File *file, PHYSFS_sint32 *val);
int PHYSFS_readULE32(PHYSFS_File *file, PHYSFS_uint32 *val);
int PHYSFS_readSBE32(PHYSFS_File *file, PHYSFS_sint32 *val);
int PHYSFS_readUBE32(PHYSFS_File *file, PHYSFS_uint32 *val);
int PHYSFS_readSLE64(PHYSFS_File *file, PHYSFS_sint64 *val);
int PHYSFS_readULE64(PHYSFS_File *file, PHYSFS_uint64 *val);
int PHYSFS_readSBE64(PHYSFS_File *file, PHYSFS_sint64 *val);
int PHYSFS_readUBE64(PHYSFS_File *file, PHYSFS_uint64 *val);

int PHYSFS_writeSLE16(PHYSFS_File *file, PHYSFS_sint16 *val);
int PHYSFS_writeULE16(PHYSFS_File *file, PHYSFS_uint16 *val);
int PHYSFS_writeSBE16(PHYSFS_File *file, PHYSFS_sint16 *val);
int PHYSFS_writeUBE16(PHYSFS_File *file, PHYSFS_uint16 *val);
int PHYSFS_writeSLE32(PHYSFS_File *file, PHYSFS_sint32 *val);
int PHYSFS_writeULE32(PHYSFS_File *file, PHYSFS_uint32 *val);
int PHYSFS_writeSBE32(PHYSFS_File *file, PHYSFS_sint32 *val);
int PHYSFS_writeUBE32(PHYSFS_File *file, PHYSFS_uint32 *val);
int PHYSFS_writeSLE64(PHYSFS_File *file, PHYSFS_sint64 *val);
int PHYSFS_writeULE64(PHYSFS_File *file, PHYSFS_uint64 *val);
int PHYSFS_writeSBE64(PHYSFS_File *file, PHYSFS_sint64 *val);
int PHYSFS_writeUBE64(PHYSFS_File *file, PHYSFS_uint64 *val);
// everything below here is physfs 2.0
int PHYSFS_isInit(void);
int PHYSFS_symbolicLinksPermitted(void);
// int PHYSFS_setAllocator(const PHYSFS_Allocator *allocator);
int PHYSFS_mount(const char *newDir, const char *mountPoint, int appendToPath);

const char *PHYSFS_getMountPoint(const char *dir);
typedef void (*PHYSFS_StringCallback)(void *data, const char *str);
typedef void (*PHYSFS_EnumFilesCallback)(void *data, const char *origdir, const char *fname);
void PHYSFS_getSearchPathCallback(PHYSFS_StringCallback c, void *d);
void PHYSFS_enumerateFilesCallback(const char *dir, PHYSFS_EnumFilesCallback c, void *d);
void PHYSFS_utf8FromUcs4(const PHYSFS_uint32 *src, char *dst, PHYSFS_uint64 len);
void PHYSFS_utf8ToUcs4(const char *src, PHYSFS_uint32 *dst, PHYSFS_uint64 len);
void PHYSFS_utf8FromUcs2(const PHYSFS_uint16 *src, char *dst, PHYSFS_uint64 len);
void PHYSFS_utf8ToUcs2(const char *src, PHYSFS_uint16 *dst, PHYSFS_uint64 len);
void PHYSFS_utf8FromLatin1(const char *src, char *dst, PHYSFS_uint64 len);
]]

physfs = {}

function physfs.init()
  ffi.C.PHYSFS_init(nil)
end

function physfs.deinit()
  ffi.C.PHYSFS_deinit()
end

function physfs.open(path, mode)
  if mode:sub(1,1) == "r" then
    f = ffi.C.PHYSFS_openRead(path)
  elseif mode:sub(1,1) == "w" then
    f = ffi.C.PHYSFS_openWrite(path)
  elseif mode:sub(1,1) == "a" then
    f = ffi.C.PHYSFS_openAppend(path)
  end
  if f ~= nil then
    return ffi.gc(f, ffi.C.PHYSFS_close)
  end
end

local file_mt =
{
  __index =
  {
    length = function(self)
      return tonumber(ffi.C.PHYSFS_fileLength(self))
    end,

    read = function(self, spec)
      local len

      if type(spec) == "number" then
        len = spec
      end

      if spec == "*all" or spec == "*a" then
        len = self:length()
      end

      local buf = ffi.new("uint8_t[?]", len)
      local ret = tonumber(ffi.C.PHYSFS_read(self, buf, 1, len))

      if ret == 0 then
        return nil
      else
        return ffi.string(buf, ret)
      end
    end,
   
    close = function(self)
      return ffi.C.PHYSFS_close(self) ~= 0
    end
  }
}

local PHYSFS_File = ffi.metatype("PHYSFS_File", file_mt)

function physfs.mount(path, mount, append)
  if append  then append = 1 else append = 0 end
  return ffi.C.PHYSFS_mount(path, mount, append) ~= 0
end

function physfs.exists(path)
  return ffi.C.PHYSFS_exists(path) ~= 0
end

function physfs.is_dir(path)
  return ffi.C.PHYSFS_isDirectory(path) ~= 0
end
physfs.is_directory = physfs.is_dir

function physfs.is_symlink(path)
  return ffi.C.PHYSFS_isSymbolicLink(path) ~= 0
end

function physfs.mkdir(path)
  return ffi.C.PHYSFS_mkdir(path) ~= 0
end

function physfs.delete(path)
  return ffi.C.PHYSFS_delete() ~= 0
end

function physfs.list(path)
  local l = ffi.C.PHYSFS_enumerateFiles(path)

  local t = {}
  local i = 0
  while tonumber(ffi.cast("intptr_t", l[i])) ~= 0 do
    t[#t+1] = ffi.string(l[i])
    i = i + 1
  end

  ffi.C.PHYSFS_freeList(l)
  return t
end

function physfs.last_error()
  s = ffi.C.PHYSFS_getLastError()
  if s ~= nil then
    return ffi.string(s)
  end
end
