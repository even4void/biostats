version 13
set more off
log using hand01, replace

// genotype data
use ../data/polymorphism, clear

describe

tabulate genotype, summarize(age)

graph twoway histogram age, by(genotype, col(3) legend(off)) ///
  freq bfcolor(gs3) blcolor(none)
graph export "figs/fig-01-01.eps", replace

oneway age genotype, bonferroni

quietly anova age genotype
anovaplot, scatter(jitter(2))
graph export "figs/fig-01-02.eps", replace

regress age i.genotype

// weight data
import delimited ../data/weight.dat, delimiter(space, collapse) ///
  varnames(nonames) clear

gen id = _n
reshape long v, i(id)
egen type = seq(), t(2) b(20)
label define type 1 "Beef" 2 "Cereal"
label values type type
egen level = seq(), t(2) b(10)
label define level 1 "Low" 2 "High"
label values level level
drop id _j
rename v weight

list in 1/5

graph box weight, over(type) over(level)
graph export "figs/fig-01-03.eps", replace

quietly capture log close
