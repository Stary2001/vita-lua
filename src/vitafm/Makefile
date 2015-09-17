OUTPUT = vitafm.lua
PROGRAM_SOURCE = $(wildcard src/programs/*.lua)
PROGRAMS = $(patsubst src/programs/%.lua, %, $(PROGRAM_SOURCE))

all: vitafm

vitafm_base:
	cp src/vitafm_base.lua $(OUTPUT)

version:
	echo "vitafm.version = \"`git describe --abbrev=7 --dirty --always --tags`\"" >> $(OUTPUT)

.NOTPARALLEL: $(PROGRAMS)
$(PROGRAMS): %: src/programs/%.lua
	(echo "vitafm.programs[\"$*\"] = function(...)" && cat $< && echo "end") >> $(OUTPUT)

types:
	cat src/types.lua >> $(OUTPUT)

vitafm: vitafm_base version $(PROGRAMS) types
	#echo "vitafm.run()" >> $(OUTPUT)

min: vitafm
	luamin -f vitafm.lua > vitafm_min.lua

clean:
	rm vitafm.lua || true
