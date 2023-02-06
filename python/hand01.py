import numpy as np
import pandas
import statsmodels.api as sm
import statsmodels.stats.multicomp as mc
from plotnine import *
from rdatasets import data
from scipy import stats
from statsmodels.formula.api import ols

theme_set(theme_minimal())

###################
## genotype data ##
###################

d = pandas.read_stata("../data/polymorphism_v13.dta")
d.dtypes

avg = d.groupby("genotype")["age"].agg([np.mean, np.std, np.size])
print(f"{avg}", end="\n\n")

p = (
    ggplot(d, aes(x="age"))
    + geom_histogram(binwidth=5, fill="steelblue", color="white")
    + facet_wrap("genotype", ncol=3)
    + labs(x="Age at diagnosis", y="Count")
)
p.save("figs/fig-01-01.pdf", height=6, width=8)

m = ols("age ~ C(genotype)", data=d).fit()
r = sm.stats.anova_lm(m, typ=2)
print(f"{r}", end="\n\n")

# FIXME(chl): Not exactly the same as Hmisc::smean.cl.normal because further
# adjustement are done in Hmisc. See also the definition of smean_cl_normal below.
avg["Lower"] = avg["mean"] - stats.norm.ppf(0.975) * avg["std"] / avg["size"]
avg["Upper"] = avg["mean"] + stats.norm.ppf(0.975) * avg["std"] / avg["size"]
avg["genotype"] = list(avg.index)

p = (
    ggplot(avg, aes(x="genotype", y="mean"))
    + geom_errorbar(aes(ymin="Lower", ymax="Upper"), width=0.1)
    + geom_point()
    + geom_jitter(d, aes(x="genotype", y="age"), width=0.05, color="gray", alpha=0.5)
    + labs(x="Genotype", y="Age at diagnosis")
)
p.save("figs/fig-01-02.pdf", height=6, width=8)

# FIXME(chl): How do we specify no correction at all instead of default Bonferroni?
# Also, check to get pooled vs. unpooled variance estimates.
comp1 = mc.MultiComparison(d["age"], d["genotype"])
tbl, _, _ = comp1.allpairtest(stats.ttest_ind)
print(f"{tbl}", end="\n\n")

print(f"{m.summary()}", end="\n\n")

#################
## weight data ##
#################

_d = pandas.read_table("../data/weight.dat", delimiter=" ", header=None)
# d = d.T.stack().rename_axis(("type", "level")).reset_index(name="weight")
d = pandas.DataFrame({"weight": np.hstack(np.array(_d).T)})  # type: ignore
d["type"] = np.repeat(["Beef", "Cereal"], 20)
d["level"] = np.tile(np.repeat(["Low", "High"], 10), 2)

p = (
    ggplot(d, aes(x="level", y="weight"))
    + geom_boxplot(position=position_dodge())
    + geom_jitter(size=0.8, width=0.05)
    + facet_wrap("type", nrow=2)
    + labs(x=None, y="Rat weight (g)")
)
p.save("figs/fig-01-03.pdf", height=6, width=8)

p = (
    ggplot(d, aes(x="level", y="weight", color="type"))
    + stat_summary(aes(group="type"), fun_y=np.mean, geom="line", size=1)
    + scale_color_manual(name="Diet type", values=["steelblue", "orange"])
    + labs(x="Diet level", y="Rat weight (g)")
)
p.save("figs/fig-01-04.pdf", height=6, width=8)


def smean_cl_normal(values, conf_level=0.95):
    xs = np.asarray(values)
    m = np.mean(xs)
    se = stats.sem(xs)
    cb = se * stats.t._ppf((1 + conf_level) / 2, len(xs) - 1)
    return pandas.Series({"mean": m, "lower": m - cb, "upper": m + cb})


avg = d.groupby(["type", "level"])["weight"].apply(smean_cl_normal)
print(f"{avg}", end="\n\n")

m1 = ols("weight ~ C(type)*C(level)", data=d).fit()
s1 = m1.summary()
print(f"{s1}", end="\n\n")

m2 = ols("weight ~ C(type)+C(level)", data=d).fit()
s2 = m2.summary()
print(f"{s2}", end="\n\n")

r = sm.stats.anova_lm(m2, m1)
print(f"{r}", end="\n\n")

# d["tx"] = m1.model.exog[:, 3]
d["tx"] = d["type"].map(str) + "." + d["level"].map(str)
mt = mc.MultiComparison(d["weight"], d["tx"])
tbl, _, _ = mt.allpairtest(stats.ttest_ind, method="bonf")
print(f"{tbl}", end="\n\n")

p = (
    ggplot(d, aes(x="tx", y="weight"))
    + geom_boxplot()
    + labs(x="Treatment (Diet type x Diet level)", y="Rat weight (g)")
)
p.save("figs/fig-01-05.pdf", height=6, width=8)

tbl = mc.pairwise_tukeyhsd(d["weight"], d["tx"])
print(f"{tbl.summary()}", end="\n\n")

######################
## toothgrowth data ##
######################

d = data("ToothGrowth")
r = d.groupby(["supp", "dose"], as_index=False)["len"].mean()

p = (
    ggplot(d, aes(x="dose", y="len", color="supp"))
    + geom_point(position=position_jitterdodge(jitter_width=0.1, dodge_width=0.25))
    + geom_line(r, aes(x="dose", y="len", color="supp"))
    + scale_color_manual(values=["steelblue", "orange"], guide=False)
    + labs(x="Dose (mg/day)", y="Length (oc. unit)")
)
p.save("figs/fig-01-06.pdf", height=6, width=8)
