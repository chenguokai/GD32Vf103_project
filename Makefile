# This is the Makefile templete for my GD32VF103 project
# Copyright 2019 - 2020 Xim
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###################

BUILD_DIR = ./build
PROJECT_NAME = test

all: \
$(BUILD_DIR)/$(PROJECT_NAME).elf \
$(BUILD_DIR)/$(PROJECT_NAME).hex \
$(BUILD_DIR)/$(PROJECT_NAME).bin \
$(BUILD_DIR)/$(PROJECT_NAME).s \

###################
## build essential flags
COMPILER_PATH = /Users/cgk/Downloads/xPacks/riscv-none-embed-gcc/8.3.0-1.1/bin
PREFIX = $(COMPILER_PATH)/riscv-none-embed-
MACHINE = -march=rv32imac -mabi=ilp32 -msmall-data-limit=8
CFLAGS = $(MACHINE)
ASFLAGS = $(MACHINE)
LDSCRIPT = ./GD32VF103x8.lds
LIBS = -nostartfiles
LIBDIR = 
LDFLAGS = $(MACHINE) -specs=nano.specs -T$(LDSCRIPT)

###################

C_SOURCES =  \
Firmware/RISCV/init.c \
Firmware/RISCV/handlers.c \
Firmware/RISCV/sbrk.c \
Firmware/RISCV/n200_func.c \
Firmware/RISCV/_exit.c \
Firmware/RISCV/close.c \
Firmware/RISCV/fstat.c \
Firmware/RISCV/isatty.c \
Firmware/RISCV/lseek.c \
Firmware/RISCV/read.c \
Firmware/RISCV/write.c \
Firmware/RISCV/write_hex.c \
Firmware/RISCV/your_printf.c \
Firmware/GD32VF103_standard_peripheral/system_gd32vf103.c \
Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_usart.c \
Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_eclic.c \
Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_rcu.c \
Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_gpio.c \
main.c \
timer.c \
systick.c 
#Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_gpio.c 
#Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_rcu.c 
#Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_timer.c 
#Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_eclic.c 
#Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_exti.c 
#Firmware/GD32VF103_standard_peripheral/Source/gd32vf103_pmu.c 
#Firmware/GD32VF103_standard_peripheral/Source/drv_usb_core.c 
#Firmware/GD32VF103_standard_peripheral/Source/drv_usb_dev.c 
#Firmware/GD32VF103_standard_peripheral/Source/drv_usbd_int.c 
#Firmware/GD32VF103_standard_peripheral/Source/usbd_core.c 
#Firmware/GD32VF103_standard_peripheral/Source/usbd_enum.c 
#Firmware/GD32VF103_standard_peripheral/Source/usbd_transc.c 


C_INCLUDES =  \
-I./ \
-IFirmware/GD32VF103_standard_peripheral \
-IFirmware/GD32VF103_standard_peripheral/Include \
-IFirmware/RISCV

C_DEFS = \
-DGD32VF103C_START \
-DUSE_STDPERIPH_DRIVER \
-DUSE_USB_FS

ASM_SOURCES =  \
Firmware/RISCV/entry.S \
Firmware/RISCV/start.S

AS_INCLUDES = 

AS_DEFS = 

###################

CC   = $(PREFIX)gcc
AS   = $(PREFIX)gcc -x assembler-with-cpp
COPY = $(PREFIX)objcopy
AR   = $(PREFIX)ar
SIZE = $(PREFIX)size
DUMP = $(PREFIX)objdump

OPT = -Og

CFLAGS += -Wall -fdata-sections -ffunction-sections -fshort-wchar
CFLAGS += -MMD -MF"$(@:%.o=%.d)"
CFLAGS += -fstack-usage
CFLAGS += -g $(OPT) $(C_DEFS) $(C_INCLUDES)

ASFLAGS += -Wall -fdata-sections -ffunction-sections
ASFLAGS += -MMD -MF"$(@:%.o=%.d)" 
ASFLAGS += -g $(OPT) $(C_DEFS) $(C_INCLUDES) $(AS_DEFS) $(AS_INCLUDES)

LDFLAGS += -g $(OPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(EXE).map,--cref -Wl,--gc-sections

OBJECTS_ASM = $(ASM_SOURCES:.S=.o)
OBJECTS = $(C_SOURCES:.c=.o)

###################
## the objects to generate
$(OBJECTS_ASM): %.o: %.S
	@$(AS) $(ASFLAGS) -c $< -o $(BUILD_DIR)/$(notdir $@)

$(OBJECTS): %.o: %.c
	@echo "building objects"
	@$(CC) $(CFLAGS) -Wa,-a,-ad  -c $< -o $(BUILD_DIR)/$(notdir $@)

$(BUILD_DIR)/$(PROJECT_NAME).elf: $(OBJECTS) $(OBJECTS_ASM)
	@echo "Building ELF files"
	@$(CC) $(addprefix $(BUILD_DIR)/, $(notdir $(OBJECTS_ASM))) $(addprefix $(BUILD_DIR)/, $(notdir $(OBJECTS)))  $(LDFLAGS) -o $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(COPY) -O ihex $< $@
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(COPY) -O binary -S $< $@
$(BUILD_DIR)/%.s: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(DUMP) -d $< > $@
###################

clean:
	-rm -fR $(BUILD_DIR)/*
	find . -type f -name "*.d" -delete
