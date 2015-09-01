TARGET_LUA = vita-lua-5.3
TARGET_LUAJIT = vita-lua-jit

BINDINGS = src/vita2d-binding.o src/input-binding.o src/http-binding.o
FFI_BINDINGS = $(wildcard src/ffi/*.c)
FFI_GLUE = $(wildcard lua/*.lua)
FFI_GLUE_C = $(patsubst %.lua, %.c, $(FFI_GLUE))
FFI_GLUE_O = $(patsubst %.lua, %.o, $(FFI_GLUE))
OBJS   = src/main.o

LIBS = -ldebugnet -lvita2d -lfreetype -lpng -lz -ljpeg -lSceTouch_stub -lSceDisplay_stub -lSceGxm_stub -lSceCtrl_stub -lSceNet_stub -lSceNetCtl_stub -lSceHttp_stub -lSceAudio_stub -lScePower_stub
LUA_LIBS = -llua -lm
LUAJIT_LIBS = -lluajit-5.1 -lm
LUAJIT_CFLAGS = -DJIT -I$(VITASDK)/arm-vita-eabi/include/luajit-2.0

PREFIX = $(VITASDK)/bin/arm-vita-eabi
DB = db.json

CC      = $(PREFIX)-gcc
LD	= $(PREFIX)-ld

DEBUGGER_IP = 192.168.1.5
DEBUGGER_PORT = 18194
DEFS = -DDEBUGGER_IP=\"$(DEBUGGER_IP)\" -DDEBUGGER_PORT=$(DEBUGGER_PORT)

CFLAGS  = -Wl,-q -Wall -O3 -std=gnu99 $(DEFS)

all: $(TARGET_LUA).velf

jit: CFLAGS += $(LUAJIT_CFLAGS)
jit: $(TARGET_LUAJIT).velf

%.velf: %.elf
	$(PREFIX)-strip -g $<
	vita-elf-create $< $@ $(DB) >/dev/null

%.c: %.lua
	./generate_init.sh $<

src/ffi_init.c: $(FFI_GLUE)
	./generate_ffi_init_list.sh

$(TARGET_LUAJIT).elf: $(OBJS) $(FFI_BINDINGS) src/ffi_init.c $(FFI_GLUE_O)
	$(CC) $(CFLAGS) $^ $(LIBS) $(LUAJIT_LIBS) -o $@

$(TARGET_LUA).elf: $(OBJS) $(BINDINGS)
	$(CC) $(CFLAGS) $^ $(LIBS) $(LUA_LIBS) -o $@

clean:
	@rm -rf $(TARGET_LUA).velf  $(TARGET_LUAJIT).velf $(TARGET_LUA).elf $(TARGET_LUAJIT).velf $(OBJS) $(BINDINGS) $(FFI_GLUE_O) $(FFI_GLUE_C) src/ffi_init.c
