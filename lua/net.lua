-- net
local ffi = require 'ffi'

ffi.cdef [[
/** Socket types */
enum {
        PSP2_NET_SOCK_STREAM            = 1,
        PSP2_NET_SOCK_DGRAM             = 2,
        PSP2_NET_SOCK_RAW               = 3,
        PSP2_NET_SOCK_DGRAM_P2P         = 6,
        PSP2_NET_SOCK_STREAM_P2P        = 10
};

typedef struct SceNetFdSet {
        unsigned int bits[32];
} SceNetFdSet;

typedef struct SceNetInAddr {
        unsigned int s_addr;
} SceNetInAddr;

typedef struct SceNetSockaddrIn {
        unsigned char sin_len;
        unsigned char sin_family;
        unsigned short int sin_port;
        SceNetInAddr sin_addr;
        unsigned short int sin_vport;
        char sin_zero[6];
} SceNetSockaddrIn;

typedef struct SceNetIpMreq {
        SceNetInAddr imr_multiaddr;
        SceNetInAddr imr_interface;
} SceNetIpMreq;

typedef struct SceNetInitParam {
        void *memory;
        int size;
        int flags;
} SceNetInitParam;
typedef struct SceNetEtherAddr {
        unsigned char data[6];
} SceNetEtherAddr;

typedef struct SceNetDnsInfo {
        SceNetInAddr dns_addr[2];
} SceNetDnsInfo;

typedef struct SceNetEpollDataExt {
        int id;
        unsigned int u32;
} SceNetEpollDataExt;

typedef union SceNetEpollData {
        void *ptr;
        int fd;
        unsigned int u32;
        unsigned long long int u64;
        SceNetEpollDataExt ext;
} SceNetEpollData;

typedef struct SceNetEpollSystemData {
        unsigned int system[4];
} SceNetEpollSystemData;

typedef struct SceNetEpollEvent {
        unsigned int events;
        unsigned int reserved;
        SceNetEpollSystemData system;
        SceNetEpollData data;
} SceNetEpollEvent;

typedef void *(*SceNetResolverFunctionAllocate)(unsigned int size, int rid, const char *name, void *user);
typedef void (*SceNetResolverFunctionFree)(void *ptr, int rid, const char *name, void *user);

typedef struct SceNetResolverParam {
        SceNetResolverFunctionAllocate allocate;
        SceNetResolverFunctionFree free;
        void *user;
} SceNetResolverParam;

typedef struct SceNetSockaddr {
        unsigned char sa_len;
        unsigned char sa_family;
        char sa_data[14];
} SceNetSockaddr;

typedef struct SceNetIovec {
        void *iov_base;
        unsigned int iov_len;
} SceNetIovec;

typedef struct SceNetMsghdr {
        void *msg_name;
        unsigned int msg_namelen;
        SceNetIovec *msg_iov;
        int msg_iovlen;
        void *msg_control;
        unsigned int msg_controllen;
        int msg_flags;
} SceNetMsghdr;

typedef struct SceNetSockInfo {
        char name[32];
        int pid;
        int s;
        char socket_type;
        char policy;
        short int reserved16;
        int recv_queue_length;
        int send_queue_length;
        SceNetInAddr local_adr;
        SceNetInAddr remote_adr;
        unsigned short int local_port;
        unsigned short int remote_port;
        unsigned short int local_vport;
        unsigned short int remote_vport;
        int state;
        int flags;
        int reserved[8];
} SceNetSockInfo;

typedef struct SceNetStatisticsInfo {

        int kernel_mem_free_size;
        int kernel_mem_free_min;
        int packet_count;
        int packet_qos_count;

        int libnet_mem_free_size;
        int libnet_mem_free_min;
} SceNetStatisticsInfo;

int sceNetInit(SceNetInitParam *param);
int sceNetTerm(void);

int sceNetShowIfconfig(void *p, int b);
int sceNetShowRoute(void);
int sceNetShowNetstat(void);

int sceNetResolverCreate(const char *name, SceNetResolverParam *param, int flags);
int sceNetResolverStartNtoa(int rid, const char *hostname, SceNetInAddr *addr, int timeout, int retry, int flags);
int sceNetResolverStartAton(int rid, const SceNetInAddr *addr, char *hostname, int len, int timeout, int retry, int flags);
int sceNetResolverGetError(int rid, int *result);
int sceNetResolverDestroy(int rid);
int sceNetResolverAbort(int rid, int flags);

int sceNetDumpCreate(const char *name, int len, int flags);
int sceNetDumpRead(int id, void *buf, int len, int *pflags);
int sceNetDumpDestroy(int id);
int sceNetDumpAbort(int id, int flags);
int sceNetEpollCreate(const char *name, int flags);
int sceNetEpollControl(int eid, int op, int id,SceNetEpollEvent *event);
int sceNetEpollWait(int eid, SceNetEpollEvent *events, int maxevents, int timeout);
int sceNetEpollWaitCB(int eid, SceNetEpollEvent *events, int maxevents, int timeout);
int sceNetEpollDestroy(int eid);
int sceNetEpollAbort(int eid, int flags);

int sceNetEtherStrton(const char *str, SceNetEtherAddr *n);
int sceNetEtherNtostr(const SceNetEtherAddr *n, char *str, unsigned int len);
int sceNetGetMacAddress(SceNetEtherAddr *addr, int flags);

int sceNetSocket(const char *name, int domain, int type, int protocol);
int sceNetAccept(int s, SceNetSockaddr *addr, unsigned int *addrlen);
int sceNetBind(int s, const SceNetSockaddr *addr, unsigned int addrlen);
int sceNetConnect(int s, const SceNetSockaddr *name, unsigned int namelen);
int sceNetGetpeername(int s, SceNetSockaddr *name, unsigned int *namelen);
int sceNetGetsockname(int s, SceNetSockaddr *name, unsigned int *namelen);
int sceNetGetsockopt(int s, int level, int optname, void *optval, unsigned int *optlen);
int sceNetListen(int s, int backlog);
int sceNetRecv(int s, void *buf, unsigned int len, int flags);
int sceNetRecvfrom(int s, void *buf, unsigned int len, int flags, SceNetSockaddr *from, unsigned int *fromlen);
int sceNetRecvmsg(int s, SceNetMsghdr *msg, int flags);
int sceNetSend(int s, const void *msg, unsigned int len, int flags);
int sceNetSendto(int s, const void *msg, unsigned int len, int flags, const SceNetSockaddr *to, unsigned int tolen);
int sceNetSendmsg(int s, const SceNetMsghdr *msg, int flags);
int sceNetSetsockopt(int s, int level, int optname, const void *optval, unsigned int optlen);
int sceNetShutdown(int s, int how);
int sceNetSocketClose(int s);
int sceNetSocketAbort(int s, int flags);
int sceNetGetSockInfo(int s, SceNetSockInfo *info, int n, int flags);
int sceNetGetSockIdInfo(SceNetFdSet *fds, int sockinfoflags, int flags);
int sceNetGetStatisticsInfo(SceNetStatisticsInfo *info, int flags);

int sceNetSetDnsInfo(SceNetDnsInfo *info, int flags);
int sceNetClearDnsCache(int flags);

const char *sceNetInetNtop(int af,const void *src,char *dst,unsigned int size);
int sceNetInetPton(int af, const char *src, void *dst);

//TODO : create BSD aliases ?

long long unsigned int sceNetHtonll(unsigned long long int host64);
unsigned int sceNetHtonl(unsigned int host32);
unsigned short int sceNetHtons(unsigned short int host16);
unsigned long long int sceNetNtohll(unsigned long long int net64);
unsigned int sceNetNtohl(unsigned int net32);
unsigned short int sceNetNtohs(unsigned short int net16);

void *malloc(int len);
void free(void* ptr);

void *resolver_malloc(unsigned int size, int rid, const char *name, void *user);
void resolver_free(void *ptr, int rid, const char *name, void *user);

void net_init(int sz);
void net_term();
int net_create_resolver(const char *name);
]]

local C = ffi.C

net = {}
dns = {}

local resolver
function dns.resolve(host)
  if resolver == nil then
    resolver = C.net_create_resolver("lua_resolver")
  end

  local addr = ffi.new("SceNetInAddr[1]")
  buf = ffi.new("uint8_t[?]", #host + 1)
  ffi.copy(buf, host)
  if C.sceNetResolverStartAton(resolver, addr, buf, #host, 1000, 0, 0) < 0 then
    return nil, r
  end
  return addr[0]
end

AF_INET = 2

local sock_mt =
{
  __index = 
  {
    connect = function(self, host, port)
      local sockaddr = ffi.new("SceNetSockaddrIn[1]")
      local a = dns.resolve(host)
      sockaddr[0].sin_addr = a
      print(tostring(sockaddr[0].sin_addr.s_addr))
      sockaddr.sin_port = C.sceHtons(port)
      local r = C.sceNetConnect(self.fd, sockaddr, ffi.sizeof("SceNetSockaddrIn"))
      if r < 0 then
        return nil, r
      end
      
      return true
    end
  }
}

local net_mem

function net.init()
  C.net_init(8192)
end

function net.term()
  C.net_term()
end

local socket_num = 0
function net.socket(proto)
  if proto == "tcp" then
    proto = C.PSP2_NET_SOCK_STREAM
  elseif proto == "udp" then
    proto = C.PSP2_NET_SOCK_DGRAM
  else
    error("invalid socket type")
  end
  
  local r = C.sceNetSocket(string.format("%d_lua_socket", socket_num), AF_INET, proto, 0)
  if r < 0 then
    return nil, r
  end
  socket_num = socket_num + 1
  local t = { fd = r }
  setmetatable(t, sock_mt)
  return t
end
