CC     := gcc
CFLAGS := -g -O0

SRC  := testprog.c diffprog.c
OBJ  := $(patsubst %.c, %.o, $(SRC))

EXEC := testprog diffprog


all: $(EXEC)

testprog : testprog.o
	$(LINK.c) -o $@ $<
diffprog : diffprog.o
	$(LINK.c) -o $@ $< -lm

neat:
	$(RM) *~
clean: neat
	$(RM) *.o
clobber: clean
	$(RM) $(EXEC)

testprog.o: testprog.c
diffprog.o: diffprog.c

