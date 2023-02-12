SRC=$(patsubst %.rkt,%.log,$(wildcard hand*.rkt))

.PHONY: all clean dist

all: dist

dist: $(SRC)

%.log: %.rkt
	racket $< | tee $@

clean:
	rm -rf *.log figs/*
