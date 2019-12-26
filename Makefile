include $(THEOS)/makefiles/common.mk

TOOL_NAME = iobat

iobat_FILES = src/main.m
iobat_CFLAGS = -fobjc-arc
iobat_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tool.mk
