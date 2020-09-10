PROG = udpechoserverd
LIB = libudpechoserver.so

PROG_OBJS = udpechoserver.o udpechoserverlog.o udpechoserveruci.o
LIB_OBJS = datamodel.o

PROG_CFLAGS = $(CFLAGS) -Wall -Werror
PROG_LDFLAGS = $(LDFLAGS) -luci
LIB_LDFLAGS = $(LDFLAGS) -lbbf_api

%.o: %.c
	$(CC) $(PROG_CFLAGS) $(FPIC) -c -o $@ $<

all: $(PROG) $(LIB)

$(PROG): $(PROG_OBJS)
	$(CC) $(PROG_CFLAGS) -o $@ $^ $(PROG_LDFLAGS)

$(LIB): $(LIB_OBJS)
	$(CC) $(PROG_CFLAGS) $(LIB_LDFLAGS) -shared -o $@ $^

clean:
	rm -f *.o $(PROG) $(LIB)
