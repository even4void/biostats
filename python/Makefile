SRC=$(patsubst %.py,%.log,$(wildcard hand*.py))

.PHONY: all clean dist

all: dist

dist: $(SRC)

%.log: %.py
	python3 $< | tee $@

clean:
	rm -rf *.log figs/*
