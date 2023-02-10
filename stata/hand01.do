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

xpose, clear
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

quietly anova weight type level type#level
anovaplot level type, scatter(ms(i)) yscale(r(75 105))
graph export "figs/fig-01-04.eps", replace

preserve
statsby, by(type level) clear: ci weight
list
restore

anova weight type level type#level
estimates store m1
anova weight type level
estimates store m2
estimates stats m1 m2
lrtest m1 m2

ttest weight, by(level)
scalar tobs = r(t)^2
display `=tobs'

pwmean weight, over(type level) pveffects mcompare(bonf)

egen tx = concat(type level), decode punct(.)
graph box weight, over(tx) b1title("Treatment (Diet type x Diet level)")
graph export "figs/fig-01-05.eps", replace

pwmean weight, over(type level) pveffects mcompare(tukey)

// ToothGrowth data
use ../data/toothgrowth, clear

summarize

egen dosec = group(dose), label
quietly anova len dosec#supp
quietly margins dosec#supp

marginsplot, noci title("") xtitle(Dose (mg/day)) ytitle(Length (oc. unit)) ///
  addplot(scatter len dosec if supp == 1, ms(oh) jitter(5) ///
  mc(ebblue) text(20 1 "OJ", color(ebblue) size(medlarge)) ///
  xscale(r(0 4)) xlab(0(1)3) || scatter len dosec if supp == 2, ///
  ms(oh) jitter(5) mc(orange) text(10 2 "VC", color(orange) ///
  size(medlarge))) scheme(uncluttered)
graph export "figs/fig-01-06.eps", replace

quietly capture log close
