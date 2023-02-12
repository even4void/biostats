#lang racket

(require data-frame)
(require "utils.rkt")

(define d (df-read/csv "../data/fev.csv"))

(df-describe d)

(recode (vector->list (df-select d "sex")))
