PROJECT := orochi
BUILD := build
TARGET := $(BUILD)/$(PROJECT).gb

ifndef GBDK_HOME
$(error GBDK_HOME is not set.)
endif

LCC := $(GBDK_HOME)/bin/lcc
GBLIB := $(GBDK_HOME)/lib/gb/gb.lib

LINKOBJS := $(BUILD)/set_data.o \
            $(BUILD)/sfr.o \
            $(BUILD)/delay.o \
            $(BUILD)/set_tile.o \
            $(BUILD)/get_addr.o \
            $(BUILD)/fill_rect.o \
            $(BUILD)/fill_rect_bk.o \

ifdef GBDK_DEBUG
LCCFLAGS += -debug -v
endif

INCLUDES := -Ires

SRC_C := $(shell find src -name '*.c' 2>/dev/null)
SRC_S := $(shell find src -name '*.s' 2>/dev/null)
RES_C := $(shell find res -name '*.c' 2>/dev/null)
RES_S := $(shell find res -name '*.s' 2>/dev/null)

OBJS := $(SRC_C:src/%.c=$(BUILD)/%.o) \
        $(SRC_S:src/%.s=$(BUILD)/%.o) \
        $(RES_C:res/%.c=$(BUILD)/%.o) \
        $(RES_S:res/%.s=$(BUILD)/%.o)

.PHONY: all run clean

all: $(TARGET)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: src/%.c | $(BUILD)
	@mkdir -p $(dir $@)
	$(LCC) $(LCCFLAGS) $(INCLUDES) -c -o $@ $<

$(BUILD)/%.o: src/%.s | $(BUILD)
	@mkdir -p $(dir $@)
	$(LCC) $(LCCFLAGS) $(INCLUDES) -c -o $@ $<

$(BUILD)/%.o: res/%.c | $(BUILD)
	@mkdir -p $(dir $@)
	$(LCC) $(LCCFLAGS) $(INCLUDES) -c -o $@ $<

$(BUILD)/%.o: res/%.s | $(BUILD)
	@mkdir -p $(dir $@)
	$(LCC) $(LCCFLAGS) $(INCLUDES) -c -o $@ $<

$(LINKOBJS): | $(BUILD)
	ar x --output=$(BUILD) $(GBLIB) $(notdir $@)

$(TARGET): $(OBJS) $(LINKOBJS)
	$(LCC) $(LCCFLAGS) -o $@ $(OBJS) $(LINKOBJS)

run: $(TARGET)
	gearboy $(TARGET)

clean:
	rm -rf $(BUILD)
