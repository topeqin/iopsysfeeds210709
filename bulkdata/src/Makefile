PROG = bulkdatad
LIB = libbulkdata.so

PROG_OBJS = bulkdata.o common.o config.o http.o log.o report.o times.o buci.o
LIB_OBJS = datamodel.o

PROG_CFLAGS = $(CFLAGS) -Wall -Werror -fPIC
PROG_LDFLAGS = $(LDFLAGS) -lubus -luci -lubox -ljson-c -lcurl -lblobmsg_json -lbbfdm
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
