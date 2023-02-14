SRC=$(patsubst %.wls,%.log,$(wildcard hand*.wls))

.PHONY: all clean dist

all: dist

dist: $(SRC)

%.log: %.wls
	wolframscript $<

clean:
	rm -rf *.log figs/*
