.PNONY:all

#---------compiler
CC := gcc -std=gnu99
LD := gcc

#-----------platform
PLATS=linux macosx
platform:
	@echo "'make PLATFORM' where PLATFORM is one of these:"
	@echo "$(PLATS)"
CCFLAG = -g -Wall -Wextra
LDFLAG := -lm -ldl

linux:CCFLAG += -D__linux__
macosx:CCFLAG += -D__macosx__

linux:LDFLAG += -Wl,-E -lrt
macosx:LDFLAG += -Wl,-no_compact_unwind
linux macosx:LDFLAG += -lpthread

linux:SHARED:=--share -fPIC
macosx:SHARED=-dynamiclib -fPIC -Wl,-undefined,dynamic_lookup

linux: PLAT := linux
macosx: PLAT := macosx

#-----------library
LUACLIB_PATH=luaclib
#-----------project
INCLUDE = -I ./silly/lua/ -I ./silly/silly-src/

linux macosx: all

all: silly/silly\
	$(LUACLIB_PATH)	\
	$(TARGET) \
	$(LUACLIB_PATH)/aoi.so \
	$(LUACLIB_PATH)/aux.so \

silly/silly:
	make -C silly/ $PLAT

$(LUACLIB_PATH):
	mkdir $(LUACLIB_PATH)

$(LUACLIB_PATH)/aoi.so: lualib-src/lualib-aoi.c lualib-src/aoi.c lualib-src/hashtable.c
	$(CC) $(CCFLAG) $(INCLUDE) -o $@ $^ $(SHARED)
$(LUACLIB_PATH)/aux.so: lualib-src/lualib-aux.c
	$(CC) $(CCFLAG) $(INCLUDE) -o $@ $^ $(SHARED)

clean:
	-rm -rf $(LUACLIB_PATH)
	make -C silly/clean

