PROJECTNAME = serpent

BINS = build/$(PROJECTNAME).gb

ifndef GBDK_HOME
	$(error GBDK_HOME is not set.)
endif

LCC = $(GBDK_HOME)/bin/lcc

ifdef GBDK_DEBUG
	LCCFLAGS += -debug -v
endif

CSOURCES := $(wildcard src/*.c)
ASMSOURCES := $(wildcard src/*.s)

all: init $(BINS)

init:
	rm -rf build
	mkdir build

$(BINS): $(CSOURCES) $(ASMSOURCES)
	$(LCC) $(LCCFLAGS) -o $@ $(CSOURCES) $(ASMSOURCES)

run: $(BINS)
	gearboy $(BINS)

clean:
	rm -f *.o *.lst *.map *.gb *.ihx *.sym *.cdb *.adb *.asm *.noi *.rst
