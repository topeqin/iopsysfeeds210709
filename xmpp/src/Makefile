PROG = xmppd
LIB = libxmpp.so

PROG_OBJS = xmpp.o xuci.o cmd.o log.o
LIB_OBJS = datamodel.o

PROG_CFLAGS = $(CFLAGS) -Wall -Werror -fPIC
PROG_LDFLAGS = $(LDFLAGS) -luci -lubox -lstrophe
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
