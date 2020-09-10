PROG = stund
OBJS = stun.o config.o log.o ubus.o

PROG_CFLAGS = $(CFLAGS) -Wall -Werror
PROG_LDFLAGS = $(LDFLAGS) -lubus -luci -lubox -ljson-c -lcrypto -lblobmsg_json

%.o: %.c
	$(CC) $(PROG_CFLAGS) $(FPIC) -c -o $@ $<

all: $(PROG)

$(PROG): $(OBJS)
	$(CC) $(PROG_CFLAGS) -o $@ $^ $(PROG_LDFLAGS)

clean:
	rm -f *.o $(PROG)
