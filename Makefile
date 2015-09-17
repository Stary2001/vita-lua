TARGET = vita-lua

BOOTSCRIPT ?= vitafm
FONT ?= src/font/UbuntuMono-R.ttf
MINIFY ?= no

FFI_BINDINGS = $(wildcard src/ffi/*.c)
FFI_GLUE     = $(wildcard lua/*.lua)
FFI_GLUE_C   = $(patsubst %.lua, %.c, $(FFI_GLUE))
FFI_GLUE_O   = $(patsubst %.lua, %.o, $(FFI_GLUE))
OBJS         = src/main.o

LIBS     = -ldebugnet -lvita2d -lfreetype -lpng -lz -ljpeg -lSceTouch_stub -lSceDisplay_stub -lSceGxm_stub -lSceCtrl_stub -lSceNet_stub -lSceNetCtl_stub -lSceHttp_stub -lSceAudio_stub -lScePower_stub -lUVLoader_stub -lluajit-5.1 -lm -lphysfs
INCLUDES = -I./includes -I$(VITASDK)/arm-vita-eabi/include/luajit-2.0

PREFIX = $(VITASDK)/bin/arm-vita-eabi
DB     = db.json extra.json

CC = $(PREFIX)-gcc
LD = $(PREFIX)-ld

DEBUGGER_IP ?= $(shell ip addr list `ip route | grep default | grep -oP 'dev \K[a-z0-9]* '` | grep -oP 'inet \K[0-9\.]*')
DEBUGGER_PORT = 18194
DEFS = -DDEBUGGER_IP=\"$(DEBUGGER_IP)\" -DDEBUGGER_PORT=$(DEBUGGER_PORT)

CFLAGS  = -Wl,-q -Wall -O3 -std=gnu99 $(DEFS) $(INCLUDES)

all: $(TARGET).velf

%.velf: %.elf
	$(PREFIX)-strip -g $<
	vita-elf-create $< $@ $(DB) >/dev/null

%.c: %.lua
	@if [ "$(MINIFY)" == "yes" ]; then \
		echo luamin $< > $<_min; \
		luamin $< > $<_min; \
		echo ./scripts/generate_init.sh $<_min $*.c; \
		./scripts/generate_init.sh $<_min $*.c; \
		echo rm $<_min; \
		rm $<_min; \
	else \
		echo ./scripts/generate_init.sh $< $*.c; \
		./scripts/generate_init.sh $< $*.c; \
	fi

src/boot.c:
	@if [ "$(BOOTSCRIPT)" == "vitafm" ]; then \
		echo ./scripts/generate_bootc.sh src/vitafm/src/vitafm_launch.lua; \
		./scripts/generate_bootc.sh src/vitafm/src/vitafm_launch.lua; \
	else \
		echo ./scripts/generate_bootc.sh $(BOOTSCRIPT); \
		./scripts/generate_bootc.sh $(BOOTSCRIPT); \
	fi

src/vitafm/vitafm.c: src/vitafm/src/vitafm_launch.lua
	if [ "$(MINIFY)" == "YES" ]; then \
		make -C src/vitafm min; \
		echo ./scripts/generate_vitafmc.sh src/vitafm/vitafm_min.lua; \
		./scripts/generate_vitafmc.sh src/vitafm/vitafm_min.lua; \
	else \
		make -C src/vitafm; \
		echo ./scripts/generate_vitafmc.sh src/vitafm/vitafm.lua; \
		./scripts/generate_vitafmc.sh src/vitafm/vitafm.lua; \
	fi

src/font.c: $(FONT)
	./scripts/generate_defaultfont.sh $<

src/ffi_init.c: $(FFI_GLUE)
	./scripts/generate_ffi_init_list.sh

$(TARGET).elf: $(OBJS) $(FFI_BINDINGS) src/ffi_init.o $(FFI_GLUE_O) src/font.o src/boot.o src/vitafm/vitafm.o
	$(CC) $(CFLAGS) $^ $(LIBS) $(LUAJIT_LIBS) -o $@

clean:
	rm -rf $(TARGET).velf $(TARGET).elf $(OBJS) $(FFI_GLUE_O) $(FFI_GLUE_C) src/ffi_init.c src/boot.c src/vitafm/vitafm.c
	make -C src/vitafm clean
