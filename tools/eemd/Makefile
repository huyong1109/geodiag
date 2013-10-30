CC = nhlcc
LD = gcc

CFLAGS = -g

D = $(GEODIAG_TOOLS)/eemd
OBJECTS = $(D)/eemd_ncl_wrapper.o $(D)/eemd.o

VPATH = $(D)

%.o: %.c
	@cd $(D) && $(CC) $(CFLAGS) -c $< 2> /dev/null
	@if [[ $$? != 0 ]]; then \
	     echo "[Error]: Failed to compile $<!"; \
	 fi

eemd.so: $(OBJECTS)
	@$(LD) -bundle -flat_namespace -undefined suppress $^ -o $@

.PHONY:
clean:
	@rm -f $(OBJECTS) eemd.so
