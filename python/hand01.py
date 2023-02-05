import numpy as np
import pandas
import statsmodels.api as sm
import statsmodels.stats.multicomp as mc
from plotnine import *
from scipy.stats import norm, ttest_ind
from statsmodels.formula.api import ols

theme_set(theme_minimal())

d = pandas.read_stata("../data/polymorphism_v13.dta")
d.dtypes

avg = d.groupby("genotype")["age"].agg([np.mean, np.std, np.size])
print(avg)

p = (
    ggplot(d, aes(x="age"))
    + geom_histogram(binwidth=5, fill="steelblue", color="white")
    + facet_wrap("genotype", ncol=3)
    + labs(x="Age at diagnosis", y="Count")
)
print(p)

m = ols("age ~ C(genotype)", data=d).fit()
r = sm.stats.anova_lm(m, typ=2)
print(r)

# FIXME(chl): Not exactly the same as Hmisc::smean.cl.normal because further
# adjustement are done in Hmisc
avg["Lower"] = avg["mean"] - norm.ppf(0.975) * avg["std"] / avg["size"]
avg["Upper"] = avg["mean"] + norm.ppf(0.975) * avg["std"] / avg["size"]
avg["genotype"] = list(avg.index)

p = (
    ggplot(avg, aes(x="genotype", y="mean"))
    + geom_errorbar(aes(ymin="Lower", ymax="Upper"), width=0.1)
    + geom_point()
    + geom_jitter(d, aes(x="genotype", y="age"), width=0.05, color="gray", alpha=0.5)
    + labs(x="Genotype", y="Age at diagnosis")
)

# FIXME(chl): How do we specify no correction at all instead of default Bonferroni?
# Also, check to get pooled vs. unpooled variance estimates.
comp1 = mc.MultiComparison(d["age"], d["genotype"])
tbl, _, _ = comp1.allpairtest(ttest_ind)
print(tbl)

m.summary()
