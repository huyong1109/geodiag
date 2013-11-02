CC = nhlcc

OS = $(shell uname)

ifeq ($(OS),Darwin)
	LD = gcc -bundle -flat_namespace -undefined suppress
endif
ifeq ($(OS),Linux)
	LD = ld -G
endif

CFLAGS = -g

D = $(GEODIAG_TOOLS)/eemd
OBJECTS = $(D)/spline.o $(D)/eemd_ncl_wrapper.o $(D)/eemd.o

VPATH = $(D)

%.o: %.c
	@cd $(D) && $(CC) $(CFLAGS) -c $< 2> /dev/null
	@if [[ $$? != 0 ]]; then \
	     echo "[Error]: Failed to compile $<!"; \
	 fi

eemd.so: $(OBJECTS)
	@$(LD) $^ -o $@

.PHONY:
clean:
	@rm -f $(OBJECTS) eemd.so
