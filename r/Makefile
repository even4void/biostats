SRC=$(patsubst %.r,%.log,$(wildcard hand*.r))

.PHONY: all clean dist

all: dist

dist: $(SRC)

%.log: %.r
	Rscript $<

clean:
	rm -rf *.log figs/*
