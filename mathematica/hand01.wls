#!/usr/bin/env -S wolframscript --print all
(* ::Package:: *)


con = OpenWrite["hand01.log"];
AppendTo[$Output, con];

d = Import["../data/polymorphism.dta", "Dataset"];

hist = GroupBy[d, "genotype"][All, Histogram[#, {30, 90, 5}] &, "age"];
g = GraphicsRow[{hist[1], hist[2], hist[2]}];
Export["figs/fig-01-01.pdf", g];

ds = Flatten /@ List @@@ Normal @ d;

Summarize[x_] := {Length[x], Mean[x], StandardDeviation[x]}
Table[{x[[1, 3]], N[Summarize[x[[All, 2]]]]}, {x, GatherBy[ds, #[[3]]&]}]

dd = MapAt[4 - #&, ds, {All, 3}];  (* change reference category *)
m = LinearModelFit[dd[[All, {3, 2}]], x, x, NominalVariables -> x];
Normal[m]
m["ANOVATable"]

(* Needs["HypothesisTesting`"] *)
(* cis = Table[{x[[1, 3]], MeanCI[x[[All, -2]]]}, {x, GatherBy[ds, #[[3]]&]}] *)

ErrorMarginNormal[x_, p_] := Quantile[NormalDistribution[0, 1], 1 - p/2] * StandardDeviation[x]/Sqrt[Length[x]]
MeanCINormal[x_] := Around[Mean[x], ErrorMarginNormal[x, .05]]
cis = Table[{x[[1, 3]], MeanCINormal[x[[All, 2]]]}, {x, GatherBy[ds, #[[3]]&]}];

ddn = MapAt[# + RandomReal[{-.05,.05}]&, ds, {All, 3}];  (* jittering on x-axis *)
xlabs = {{1, "1.6/1.6"}, {2, "1.6/0.7"}, {3, "0.7/0.7"}};
g = Show[ListPlot[ddn[[All, {3, 2}]], Ticks -> {xlabs, Automatic},
  AxesLabel -> {Genotype, Age}, PlotRange -> {{0.5, 3.5}, Automatic}],
  ListPlot[cis]];
Export["figs/fig-01-02.pdf", g];

d = Import["../data/toothgrowth.dta", "Dataset"];
ds = Flatten /@ List @@@ Normal @ d;

avg = Table[{x[[1, 3]], Mean[x[[All, 1]]]}, {x, GatherBy[ds, #[[{2, 3}]]&]}];

ddn = MapAt[# + RandomReal[{-.05,.05}]&, ds, {All, 3}];
ddn = SplitBy[ddn, #[[2]]&];

g = Show[ListPlot[ddn[[All, All, {3, 1}]], AxesLabel -> {Dose, Length},
  PlotRange -> {{0.25, 2.25}, Automatic}, GridLines -> Automatic],
  ListPlot[Take[avg, 3], Joined -> True, PlotStyle -> ColorData[97][1]],
  ListPlot[Take[avg, -3], Joined -> True, PlotStyle -> ColorData[97][2]]];
Export["figs/fig-01-06.pdf", g];

Close[con];
