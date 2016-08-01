TARGET = vita-lua
TITLE_ID = STAR00001

BOOTSCRIPT ?= src/vitafm/src/vitafm_launch.lua
FONT ?= src/font/UbuntuMono-R.ttf

FFI_BINDINGS = $(wildcard src/ffi/*.c)
FFI_BINDINGS_O = $(patsubst %.c, %.o, $(FFI_BINDINGS))

OBJS         = src/main.o

LIBS     = -ldebugnet -lvita2d -lfreetype -lpng -lz -ljpeg -lSceTouch_stub -lSceDisplay_stub -lSceGxm_stub -lSceCtrl_stub -lSceNet_stub -lSceNetCtl_stub -lSceHttp_stub -lSceAudio_stub -lScePower_stub -lSceSysmodule_stub -lluajit-5.1 -lm -lphysfs
INCLUDES = -I./includes -I$(VITASDK)/arm-vita-eabi/include/luajit-2.0

PREFIX = $(VITASDK)/bin/arm-vita-eabi

CC = $(PREFIX)-gcc
LD = $(PREFIX)-ld

DEBUGGER_IP ?= $(shell ip addr list `ip route | grep default | grep -oP 'dev \K[a-z0-9]* '` | grep -oP 'inet \K[0-9\.]*')
DEBUGGER_PORT = 18194
DEFS = -DDEBUGGER_IP=\"$(DEBUGGER_IP)\" -DDEBUGGER_PORT=$(DEBUGGER_PORT)

CFLAGS  = -Wl,-q -Wall -O3 -std=gnu99 $(DEFS) $(INCLUDES)

all: $(TARGET).vpk

$(TARGET).vpk: eboot.bin lua/vitafm.lua $(BOOTSCRIPT)
	mkdir vpktmp/sce_sys -p || true
	vita-mksfoex -s TITLE_ID=$(TITLE_ID) "$(TARGET)" vpktmp/sce_sys/param.sfo
	cp eboot.bin vpktmp/eboot.bin
	cp $(BOOTSCRIPT) vpktmp/boot.lua
	cp $(FONT) vpktmp/default_font.ttf
	cp lua/ vpktmp/ -r
	cd vpktmp && zip ../$@ -r *

eboot.bin: $(TARGET).velf
	vita-make-fself $< $@

%.velf: %.elf
	$(PREFIX)-strip -g $<
	vita-elf-create $< $@ >/dev/null

lua/vitafm.lua:
	make -C src/vitafm; \
	cp src/vitafm/vitafm.lua lua/vitafm.lua

src/ffi_init.c: $(FFI_BINDINGS_O)
	./scripts/generate_ffi_init_list.sh

$(TARGET).elf: $(OBJS) $(FFI_BINDINGS_O) src/ffi_init.o
	$(CC) $(CFLAGS) $^ $(LIBS) $(LUAJIT_LIBS) -o $@

clean:
	rm -rf $(TARGET).velf $(TARGET).elf $(OBJS) src/ffi_init.c
	make -C src/vitafm clean

vpksend: $(TARGET).vpk
	curl -T $(TARGET).vpk ftp://$(PSVITAIP):1337/ux0:/
	@echo "Sent."

send: eboot.bin
	curl -T eboot.bin ftp://$(PSVITAIP):1337/ux0:/app/$(TITLE_ID)/
	@echo "Sent."
