SRC=$(patsubst %.do,%.log,$(wildcard hand*.do))

.PHONY: all clean dist

all: dist

dist: $(SRC)

%.log: %.do
	stata -b do $<

clean:
	rm -rf *.log figs/*
