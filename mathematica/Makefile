SRC=$(patsubst %.wls,%.log,$(wildcard hand*.wls))

.PHONY: all clean dist

all: dist

dist: $(SRC)

%.log: %.wls
	wolframscript -format PDF $< | tee $@

clean:
	rm -rf *.log figs/*
