# This is the name that our final kernel executable will have.
# Change as needed.
KERNEL := MonkaOS.elf
 
# It is highly recommended to use a custom built cross toolchain to build a kernel.
# We are only using "cc" as a placeholder here. It may work by using
# the host system's toolchain, but this is not guaranteed.
CC ?= cc
 
# Likewise, "ld" here is just a placeholder and your mileage may vary if using the
# host's "ld".
LD ?= ld

OBJDIR := obj
SRCDIR := src
 
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
HEADER_DEPS := $(CFILES:.c=.d)
 
# Default target.
.PHONY: all
all: $(KERNEL)
 
# Link rules for the final kernel executable.
$(KERNEL): $(OBJ)
	$(LD) $(OBJ) $(LDFLAGS) $(INTERNALLDFLAGS) -o $@
 
# Compilation rules for *.c files.
-include $(HEADER_DEPS)
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) $(INTERNALCFLAGS) -c $< -o $@
 
# Remove object files and the final executable.
.PHONY: clean
clean:
	rm -rf $(KERNEL) $(OBJ) $(HEADER_DEPS)