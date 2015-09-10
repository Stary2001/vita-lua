#include <stddef.h>
#include <stub_ffi.h>
#include <psp2/net/net.h>
#include <stdlib.h>

void *resolver_malloc(unsigned int size, int rid, const char *name, void *user)
{
        return malloc(size);
}

void resolver_free(void *ptr, int rid, const char *name, void *user)
{
        free(ptr);
}

void* net_mem = NULL;
void net_init(int sz)
{
    if(sceNetShowNetstat() < 0)
    {
        SceNetInitParam p;
        p.memory = malloc(sz);
        p.size = sz;
        p.flags = 0;
        sceNetInit(&p);
    }
}

void net_term()
{
    sceNetTerm();
    if(net_mem)
    {
        free(net_mem);
        net_mem = NULL;
    }
}

int net_create_resolver(const char *n)
{
    SceNetResolverParam p;
    p.allocate = resolver_malloc;
    p.free = resolver_free;
    p.user = NULL;
    return sceNetResolverCreate(n, &p, 0);
}

void ffi_register_net()
{
	static Function funcs[] =
	{
                {"sceNetInit", sceNetInit},
                {"sceNetTerm", sceNetTerm},
                {"sceNetShowIfconfig", sceNetShowIfconfig},
                {"sceNetShowRoute", sceNetShowRoute},
                {"sceNetShowNetstat", sceNetShowNetstat},
                {"sceNetResolverCreate", sceNetResolverCreate},
                {"sceNetResolverStartNtoa", sceNetResolverStartNtoa},
                {"sceNetResolverStartAton", sceNetResolverStartAton},
                {"sceNetResolverGetError", sceNetResolverGetError},
                {"sceNetResolverDestroy", sceNetResolverDestroy},
                {"sceNetResolverAbort", sceNetResolverAbort},
                {"sceNetDumpCreate", sceNetDumpCreate},
                {"sceNetDumpRead", sceNetDumpRead},
                {"sceNetDumpDestroy", sceNetDumpDestroy},
                {"sceNetDumpAbort", sceNetDumpAbort},
                {"sceNetEpollCreate", sceNetEpollCreate},
                {"sceNetEpollControl", sceNetEpollControl},
                {"sceNetEpollWait", sceNetEpollWait},
                {"sceNetEpollWaitCB", sceNetEpollWaitCB},
                {"sceNetEpollDestroy", sceNetEpollDestroy},
                {"sceNetEpollAbort", sceNetEpollAbort},
                {"sceNetEtherStrton", sceNetEtherStrton},
                {"sceNetEtherNtostr", sceNetEtherNtostr},
                {"sceNetGetMacAddress", sceNetGetMacAddress},
                {"sceNetSocket", sceNetSocket},
                {"sceNetAccept", sceNetAccept},
                {"sceNetBind", sceNetBind},
                {"sceNetConnect", sceNetConnect},
                {"sceNetGetpeername", sceNetGetpeername},
                {"sceNetGetsockname", sceNetGetsockname},
                {"sceNetGetsockopt", sceNetGetsockopt},
                {"sceNetListen", sceNetListen},
                {"sceNetRecv", sceNetRecv},
                {"sceNetRecvfrom", sceNetRecvfrom},
                {"sceNetRecvmsg", sceNetRecvmsg},
                {"sceNetSend", sceNetSend},
                {"sceNetSendto", sceNetSendto},
                {"sceNetSendmsg", sceNetSendmsg},
                {"sceNetSetsockopt", sceNetSetsockopt},
                {"sceNetShutdown", sceNetShutdown},
                {"sceNetSocketClose", sceNetSocketClose},
                {"sceNetSocketAbort", sceNetSocketAbort},
                {"sceNetGetSockInfo", sceNetGetSockInfo},
                {"sceNetGetSockIdInfo", sceNetGetSockIdInfo},
                {"sceNetGetStatisticsInfo", sceNetGetStatisticsInfo},
                {"sceNetSetDnsInfo", sceNetSetDnsInfo},
                {"sceNetClearDnsCache", sceNetClearDnsCache},
                {"sceNetInetNtop", sceNetInetNtop},
                {"sceNetInetPton", sceNetInetPton},
                {"sceNetHtonll", sceNetHtonll},
                {"sceNetHtonl", sceNetHtonl},
                {"sceNetHtons", sceNetHtons},
                {"sceNetNtohll", sceNetNtohll},
                {"sceNetNtohl", sceNetNtohl},
                {"sceNetNtohs", sceNetNtohs},
                {"net_init", net_init},
                {"net_term", net_term},
		{"net_create_resolver", net_create_resolver},
		{NULL, NULL}
	};
	static FunctionTable table = { .funcs = funcs, .next = NULL };
	ffi_add_table(&table);
}
