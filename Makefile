PROJECT := serpent
BUILD := build
TARGET := $(BUILD)/$(PROJECT).gb

ifndef GBDK_HOME
$(error GBDK_HOME is not set.)
endif

LCC := $(GBDK_HOME)/bin/lcc

GBLIB := $(GBDK_HOME)/lib/gb/gb.lib
LINKOBJS := $(BUILD)/set_data.o $(BUILD)/sfr.o

ifdef GBDK_DEBUG
LCCFLAGS += -debug -v
endif

SRC_C := $(wildcard src/*.c)
SRC_S := $(wildcard src/*.s)
OBJS  := $(SRC_C:src/%.c=$(BUILD)/%.o) $(SRC_S:src/%.s=$(BUILD)/%.o)

.PHONY: all run clean

all: $(TARGET)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: src/%.c | $(BUILD)
	$(LCC) $(LCCFLAGS) -c -o $@ $<

$(BUILD)/%.o: src/%.s | $(BUILD)
	$(LCC) $(LCCFLAGS) -c -o $@ $<

$(LINKOBJS) &: | $(BUILD)
	ar x --output=$(BUILD) $(GBLIB) $(notdir $(LINKOBJS))

$(TARGET): $(OBJS) $(LINKOBJS)
	$(LCC) $(LCCFLAGS) -o $@ $(OBJS) $(LINKOBJS)

run: $(TARGET)
	gearboy $(TARGET)

clean:
	rm -rf $(BUILD)
