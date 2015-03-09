.SUFFIXES: .tar.gz .c
override CFLAGS += -Wall -O0 -g -lbluetooth -lncurses
VERSION=0.0.1
LIBS=-lbluetooth -lm
btle_alarm:btle_alarm.c
all: btle_alarm btle_alarm.tar.gz
%.tar.gz: DIR=$(subst .tar.gz,,$@)
%.tar.gz: %.c
	@mkdir -p ./$(DIR)-0.1
	@cp $^ Makefile ./$(DIR)-$(VERSION)
	tar -cz -f $@ ./$(DIR)-$(VERSION)
clean:
	rm -f *.tar.gz
	rm -f btle_alarm
	rm -f *.o
	rm -rf btle_alarm-*
