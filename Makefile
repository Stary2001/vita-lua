TARGET = vita-lua
OBJS   = src/main.o src/vita2d-binding.o src/input-binding.o

LIBS = -ldebugnet -llua -lvita2d -lfreetype -lpng -lz -lSceTouch_stub -lSceDisplay_stub -lSceGxm_stub -lSceCtrl_stub -lSceNet_stub -lSceNetCtl_stub -lm

PREFIX = $(VITASDK)/bin/arm-vita-eabi
DB = /home/stary2001/vita-headers/db.json

CC      = $(PREFIX)-gcc
LD	= $(PREFIX)-ld

CFLAGS  = -Wl,-q -Wall -O3 -std=gnu99

all: $(TARGET).velf

%.velf: %.elf
	$(PREFIX)-strip -g $<
	vita-elf-create $< $@ $(DB) >/dev/null

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $^ $(LIBS) -o $@

clean:
	@rm -rf $(TARGET).velf $(TARGET).elf $(OBJS)
