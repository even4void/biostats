#!/usr/bin/env wolframscript
(* ::Package:: *)

con = OpenWrite["hand01.log"];
AppendTo[$Output, con];

d = Import["../data/polymorphism.dta", "Dataset"];

avg = d[GroupBy["genotype"], First, Mean];
Print[avg]

ds = d[GroupBy["genotype"]];
hist = ds[All, Histogram[#, {30, 90, 5}] &, "age"];
g = GraphicsRow[{hist[1], hist[2], hist[2]}]
Export["figs/fig-01-01.pdf", g]

Close[con];
