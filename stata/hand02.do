version 13
set more off
log using hand02, replace

// FEV data
import delimited ../data/fev.csv, clear

describe, simple
summarize id-height
tabulate sex
tabulate smoke

codebook age
replace age = 4 if age == 3
replace age = 18 if age == 19
replace height = height * 2.54
generate lfev = log(fev)
order lfev, after(fev)
encode sex, gen(sex_)
drop sex
rename sex_ sex
encode smoke, gen(smoke_)
drop smoke
rename smoke_ smoke

twoway kdensity age, name(h1)
twoway kdensity fev, name(h2)
twoway kdensity height, name(h3)
graph combine h1 h2 h3, row(1)
graph export "figs/fig-02-01.eps", replace

graph box age, over(smoke) over(sex) name(h4)
graph box fev, over(smoke) over(sex) name(h5)
graph combine h4 h5, row(2)
graph export "figs/fig-02-02.eps", replace

twoway scatter fev age if sex == 1, ytitle(FEV) mc(ebblue) ms(oh) ///
  || scatter fev age if sex == 2, mc(orange) ms(oh) ///
  || lowess fev age, legend(off) name(h6)
twoway scatter fev height if sex == 1, ytitle(Height) mc(ebblue) ms(oh) ///
  || scatter fev height if sex == 2, mc(orange) ms(oh) ///
  || lowess fev height, legend(off) name(h7)
graph combine h6 h7, row(1)
graph export "figs/fig-02-03.eps", replace

regress fev height
predict yhat
predict double rstd, rstandard

lowess rstd yhat, yline(-2) yline(2)
graph export "figs/fig-02-04.eps", replace

generate fevsqr3 = fev^(1/3)
drop yhat rstd
quietly regress fevsqr3 height
predict yhat
predict double rstd, rstandard
gen outliers = 0
replace outliers = 1 if abs(rstd) > 3
tostring id, gen(id_)

twoway lowess rstd yhat, ms(i) yline(-2) yline(2) ///
  || scatter rstd yhat if outliers, mlabel(id_) ///
  || scatter rstd yhat if outliers == 0, ms(oh) ///
  legend(off) ytitle(Standard residuals) ms(o)
graph export "figs/fig-02-05.eps", replace

predict cook, cooksd, if e(sample)
dfbeta
list in 1/5

gen height2 = height^2
regress fev height height2
predict yhat1
label variable yhat1 "Quadratic term"
estimates store m1
orthpoly height, deg(3) generate(heightpw*)
regress fev heightpw*
predict yhat2
label variable yhat2 "Orthogonal polynomials"
estimates store m2
// Note: To reproduce rms::rcs, we would need the following steps:
// _pctile height, p(10 50 90)
// local k1 = r(r1)
// local k2 = r(r2)
// local k3 = r(r3)
// mkspline height3 = height, cubic knots(`k1' `k2' `k3')
mkspline height3 = height, cubic
regress fev height3*
predict yhat3
label variable yhat3 "Restricted cubic splines"
estimates store m3
fp <height>, scale: regress fev <height>
// or, maybe:
// mfp, df(height:4) : regress fev height
predict yhat4
label variable yhat4 "Fractional polynomial"
estimates store m4
estimates table m*
estimates drop m*

twoway scatter fev height, ms(oh) ///
  || connected yhat1 height,  sort(height) ms(i) lc(ebblue) lp(l) ///
  || connected yhat2 height, sort(height) ms(i) lc(orange) lp(l) ///
  || connected yhat3 height, sort(height) ms(i) lc(erose) lp(l) ///
  || connected yhat4 height, sort(height) ms(i) lc(stone) lp(l) ///
  ytitle(Fitted values) legend(order(2 3 4 5) position(11) ring(0))
graph export "figs/fig-02-06.eps", replace

regress fev c.smoke

ttest fev, by(smoke)

xtile ageQ4 = age, nq(4)
tabstat fev, by(ageQ4) stats(mean sd)

// egen fevQ4mean = mean(fev), by(ageQ4)
preserve
collapse (mean) fev, by(ageQ4)
generate diff = fev[_n] - fev[1]
list
restore

regress fev age
regress fev ageQ4
anova fev ageQ4

gen high = 6
gen low = 0
graph twoway (rarea low high age if age <= 9, sort color(gs14)) (scatter fev age if smoke == 1, mc(orange) ms(oh) text(1.5 14 "current smoker", color(orange) size(medlarge))) (scatter fev age if smoke == 2, mc(ebblue) ms(oh) text(5 8 "non-current smoker", color(ebblue) size(medlarge))) (lowess fev age if smoke == 1, lc(orange) lp(l)) (lowess fev age if smoke == 2, lc(ebblue) lp(l)), legend(off) xtitle (Age (yr.)) ytitle (FEV (l/g))
graph export "figs/fig-02-07.eps", replace

drop high low

regress fev age
estimates store m1
regress fev age smoke
estimates store m2
estimates table m*
estimates stats m*
estimates drop m*

regress fev age ib2.smoke c.age#ib2.smoke

graph twoway (lfitci fev age if smoke == 1, lc(orange) acolor(gs14) fcolor(gs14) lp(l)) (lfitci fev age if smoke == 2, lc(ebblue) acolor(gs14) fcolor(gs14) lp(l)) (scatter fev age if smoke == 1, mc(orange) ms(oh) text(1.5 14 "current smoker", color(orange) size(medlarge))) (scatter fev age if smoke == 2, mc(ebblue) ms(oh) text(5 8 "non-current smoker", color(ebblue) size(medlarge))), legend(off) xtitle (Age (yr.)) ytitle (FEV (l/g))
graph export "figs/fig-02-08.eps", replace

gen age2 = age^2
regress fev age age2 ib2.smoke c.age#ib2.smoke

quietly capture log close
