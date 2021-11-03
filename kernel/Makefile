# This is the name that our final kernel executable will have.
# Change as needed.
KERNEL := MonkaOS.elf
 
# It is highly recommended to use a custom built cross toolchain to build a kernel.
# We are only using "cc" as a placeholder here. It may work by using
# the host system's toolchain, but this is not guaranteed.
CC ?= gcc

ASM ?= nasm
 
# Likewise, "ld" here is just a placeholder and your mileage may vary if using the
# host's "ld".
LD ?= ld

OBJDIR := obj
SRCDIR := src
LOGDIR := $(OBJDIR)/log
 
# User controllable CFLAGS.
CFLAGS ?= -Wall -Wextra -O2 -pipe
 
# User controllable linker flags. We set none by default.
LDFLAGS ?=
 
# Internal C flags that should not be changed by the user.
INTERNALCFLAGS :=            \
	-I.                  \
	-std=gnu11           \
	-ffreestanding       \
	-fno-stack-protector \
	-fpie                \
	-mno-80387           \
	-mno-mmx             \
	-mno-3dnow           \
	-mno-sse             \
	-mno-sse2            \
	-mno-red-zone        \
        -MMD
 
# Internal linker flags that should not be changed by the user.
INTERNALLDFLAGS :=             \
	-Tlinker.ld            \
	-nostdlib              \
	-zmax-page-size=0x1000 \
	-static                \
	-pie                   \
	--no-dynamic-linker    \
	-ztext
 
# Use find to glob all *.c files in the directory and extract the object names.
CFILES := $(shell find ./ -type f -name '*.c')
OBJ := $(subst $(SRCDIR),$(OBJDIR),$(CFILES:.c=.o))
LOGFILES := $(subst $(SRCDIR),$(OBJDIR)/log,$(CFILES:.c=.o.log))
HEADER_DEPS := $(CFILES:.c=.d)
 
include ../mk/strings.mk

# Default target.
.PHONY: all
all: dirs $(KERNEL)
 
# Link rules for the final kernel executable.
$(KERNEL): $(OBJ)
	@printf "%b" "$(LD_COLOUR)$(LD_STRING)$(FILES_COLOUR) $(shell echo -e "$(OBJ) " | tr -cd ' \t' | wc -c) files -> $(ELF_COLOUR)$(KERNEL)$(NO_COLOUR) "
	@if $(LD) $(OBJ) $(LDFLAGS) $(INTERNALLDFLAGS) -o $@ &>$@.log; then		\
		if [ -s $(subst $(OBJDIR),$(LOGDIR),$@.log) ]; then 												\
			printf "%b" "$(WARN_COLOUR)$(WARN_STRING)$(NO_COLOUR)\n";			\
		else																\
			printf "%b" "$(OK_COLOUR)$(OK_STRING)$(NO_COLOUR)\n";			\
		fi																	\
	else																	\
		printf "%b" "$(ERROR_COLOUR)$(ERROR_STRING)$(NO_COLOUR)\n";			\
	fi
	
 
# Compilation rules for *.c files.
-include $(HEADER_DEPS)
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@printf "%b" "$(COM_COLOUR)$(COM_STRING)$(OBJ_COLOUR)$(subst $(OBJDIR)/,"", $@)$(NO_COLOUR) ";
	@if $(CC) $(CFLAGS) $(INTERNALCFLAGS) -c $< -o $@ &> $(subst $(OBJDIR),$(LOGDIR),$@.log); then		\
		if [ -s $(subst $(OBJDIR),$(LOGDIR),$@.log) ]; then 												\
			printf "%b" "$(WARN_COLOUR)$(WARN_STRING)$(NO_COLOUR)\n";			\
		else																\
			printf "%b" "$(OK_COLOUR)$(OK_STRING)$(NO_COLOUR)\n";			\
		fi																	\
	else																	\
		printf "%b" "$(ERROR_COLOUR)$(ERROR_STRING)$(NO_COLOUR)\n";			\
	fi																		\

$(OBJDIR)/%.o: $(SRCDIR)/%.S
	@printf "%b" "$(COM_COLOUR)$(COM_STRING)$(OBJ_COLOUR)$(subst $(OBJDIR)/,"", $@)$(NO_COLOUR) ";
	@if $(ASM) $(CFLAGS) $(INTERNALCFLAGS) -S -c $< -o $@ &> $(subst $(OBJDIR),$(LOGDIR),$@.log); then		\
# Remove object files and the final executable.
.PHONY: clean
clean:
	rm -rf $(KERNEL) $(OBJ) $(HEADER_DEPS) $(LOGFILES)

dirs:
	mkdir -p obj/log