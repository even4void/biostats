import numpy
import pandas
from plotnine import *

theme_set(theme_minimal())

##############
## FEV data ##
##############

d = pandas.read_csv("../data/fev.csv")
d.dtypes

d.describe().loc[["min", "25%", "50%", "75%", "max"]]

d["sex"] = d["sex"].astype("category")
d["smoke"] = d["smoke"].astype("category")
d["sex"].describe()
d.groupby("sex")["smoke"].value_counts().unstack(fill_value=0)

d.loc[d["age"] == 3, "age"] = 4
d.loc[d["age"] == 19, "age"] = 18
d["height"] = d["height"] * 2.54
d["lfev"] = numpy.log(d["fev"])

dm = pandas.melt(d, id_vars=["id"], value_vars=["age", "fev", "height"])

p = (
    ggplot(dm, aes(x="value"))
    + geom_density(color="steelblue")
    + facet_wrap("variable", ncol=3, scales="free")
    + labs(x="", y="Density")
)
p.save("figs/fig-02-01.pdf", height=6, width=8)
