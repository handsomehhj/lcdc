# Make file generated by Gnu17 Plug-in for Eclipse
# This file should be placed directly under the project folder

# macro definitions for target file
TARGET= stn2tft
GOAL= $(TARGET).elf

# macro definitions for tools
TOOL_DIR= C:/EPSON/GNU17
CC= $(TOOL_DIR)/xgcc
AS= $(TOOL_DIR)/xgcc
AS_CC= $(TOOL_DIR)/as
LD= $(TOOL_DIR)/ld
RM= $(TOOL_DIR)/rm
SED= $(TOOL_DIR)/sed
CP= $(TOOL_DIR)/cp
OBJDUMP= $(TOOL_DIR)/objdump
OBJCOPY= $(TOOL_DIR)/objcopy
MOTO2FF= $(TOOL_DIR)/moto2ff
SCONV= $(TOOL_DIR)/sconv32
VECCHECKER= $(TOOL_DIR)/vecChecker

# macro definitions for tool flags
CFLAGS= -B$(TOOL_DIR)/ -mno-sjis-filt -gstabs -S  -O1 -I$(TOOL_DIR)/include -fno-builtin -Wall -Werror-implicit-function-declaration  
ASFLAGS= -B$(TOOL_DIR)/ -mno-sjis-filt -c -xassembler-with-cpp -Wa,--gstabs  
ASFLAGS_CC=  
LDFLAGS=  -Map stn2tft.map -N -T stn2tft_gnu17IDE.lds  
EXTFLAGS= -Wa,-mc17_ext -Wa,$(TARGET).dump -Wa,$(TARGET).map
EXTFLAGS_CC= -mc17_ext $(TARGET).dump $(TARGET).map
OBJDUMPFLAGS= -t
OBJCOPYFLAGS= -I elf32-little -O srec --srec-forceS3
MOTOSTART= 8000
MOTOSIZE= 10000
MOTOPROGSIZE= 10000
SCONVFLAGS= S2
VECCHECKERFLAGS= -t symtable.out -r raw.out
VECCHECKER_ON= false

# macro for switching 2pass or 1pass build
PASS= 2pass
# use or unuse flash protect bit
PROTECT_ON= false

# search paths for source files
vpath %.c 
vpath %.s 

# macro definitions for object files
OBJS= main.o \
      stn2tft.o \
      vector.o \
      
# macro definitions for library files
OBJLDS= $(TOOL_DIR)/lib/24bit/libstdio.a \
        $(TOOL_DIR)/lib/24bit/libc.a \
        $(TOOL_DIR)/lib/24bit/libgcc.a \
        $(TOOL_DIR)/lib/24bit/libc.a \
        
# macro definitions for assembly files generated from c source files
CEXTTEMPS= main.ext0 \
      stn2tft.ext0 \
      vector.ext0 \
      

# macro definitions for dependency files
DEPS= $(OBJS:%.o=%.d)
SED_PTN= 's/[[:space:]]\([a-zA-Z]\)\:/ \/cygdrive\/\1/g'
SED_PTN2= 's/^\($(subst .,\.,$(@F))\)\:/$(subst /,\/,$(@))\:/g'

# macro definitions for creating dependency files
DEPCMD_CC= @$(CC) -M -MG $(CFLAGS) $< | $(SED) -e $(SED_PTN) | $(SED) -e $(SED_PTN2) >$(@:%.o=%.d)
DEPCMD_AS= @$(AS) -M -MG $(ASFLAGS) $< | $(SED) -e $(SED_PTN) | $(SED) -e $(SED_PTN2) >$(@:%.o=%.d)

# targets and dependencies
.PHONY : all clean

all : $(GOAL)

$(TARGET).psa : $(TARGET).elf 
# clean psa files
	$(RM) -f $(TARGET).sa $(TARGET).saf $(TARGET).psa 
# create psa file from elf
	$(OBJCOPY) $(OBJCOPYFLAGS) $< $(TARGET).sa
	$(MOTO2FF) $(MOTOSTART) $(MOTOSIZE) $(TARGET).sa 
	$(SCONV) $(SCONVFLAGS) $(TARGET).saf $(TARGET).psa

# create protected psa file
ifeq ($(PROTECT_ON), true)
	$(TOOL_DIR)/gdb.exe --nw --command=protect.cmd
	$(SCONV) $(SCONVFLAGS) temp $(TARGET)_ptd.psa
	$(RM) -f temp
endif
	@cmd /c "echo ---------------- Finished building target : $@ ----------------"

$(TARGET).elf : $(OBJS) stn2tft_gnu17IDE.mak stn2tft_gnu17IDE.lds
ifeq ($(PASS), 1pass)
# 1pass linking
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(OBJLDS) 
else
# 1pass linking
	-$(LD) $(LDFLAGS) -o $@ $(OBJS) $(OBJLDS) 2>lderr 
	@if [ -s lderr ]; then \
		cmd /c "type lderr" \
		&& $(RM) -f $(TARGET).elf \
		&& exit 1; \
	else $(RM) -f lderr ; \
	fi
	$(OBJDUMP) $(OBJDUMPFLAGS) $@ > $(TARGET).dump 
	$(RM) -f $(TARGET).elf 
# save 1pass object files
	@if [ -e obj1pass ]; then \
		cmd /c "rd /s /q obj1pass" ; \
	fi
	cmd /c "md obj1pass"
	for NAME in $(subst /,\\,$(OBJS)) ; do \
		cmd /c "copy /y $$NAME obj1pass\\$$NAME" >nul ; done \
	&& $(RM) -f $(OBJS)
# 2pass for assembly files
# 2pass for c files
	for NAME in $(basename $(CEXTTEMPS))  ; do \
		$(AS_CC) $(ASFLAGS_CC) $(EXTFLAGS_CC) -o $$NAME.o $$NAME.ext0 ; done
	$(RM) -f $(TARGET).map 
# 2pass linking
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(OBJLDS) 
# restore 1pass object files
	$(RM) -f $(OBJS) \
	&& \
	for NAME in $(subst /,\\,$(OBJS)) ; do \
		cmd /c "copy /y obj1pass\\$$NAME $$NAME" >nul ; done \
	&& cmd /c "rd /s /q obj1pass"
endif

# check copro function in vector
ifeq ($(VECCHECKER_ON), true)
	$(RM) -f symtable.out raw.out
	$(OBJDUMP) -t $@ > symtable.out
	$(OBJDUMP) -s $@ > raw.out
	$(VECCHECKER) -t symtable.out -r raw.out
endif

	@cmd /c "echo ---------------- Finished building target : $@ ----------------"

## main.c
main.o : main.c main.ext0
	$(CC) $(CFLAGS) -o $(@:%.o=%.ext0) $<
	$(AS_CC) $(ASFLAGS_CC) -o $@ $(@:%.o=%.ext0) 
	$(DEPCMD_CC)

## stn2tft.c
stn2tft.o : stn2tft.c stn2tft.ext0
	$(CC) $(CFLAGS) -o $(@:%.o=%.ext0) $<
	$(AS_CC) $(ASFLAGS_CC) -o $@ $(@:%.o=%.ext0) 
	$(DEPCMD_CC)

## vector.c
vector.o : vector.c vector.ext0
	$(CC) $(CFLAGS) -o $(@:%.o=%.ext0) $<
	$(AS_CC) $(ASFLAGS_CC) -o $@ $(@:%.o=%.ext0) 
	$(DEPCMD_CC)


# dependecies for assembled c source files
main.ext0 : main.c
stn2tft.ext0 : stn2tft.c
vector.ext0 : vector.c

# include dependency files
-include $(DEPS)

# clean files
clean :
	$(RM) -f $(OBJS) $(TARGET).elf $(TARGET).map $(DEPS) $(CEXTTEMPS) $(TARGET).dump lderr $(TARGET).sa $(TARGET).saf $(TARGET).psa $(TARGET)_ptd.psa 
	@if [ -e obj1pass ]; then \
		cmd /c "rd /s /q obj1pass" ; \
	fi
