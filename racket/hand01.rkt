#lang racket

(require data-frame)

(define d (df-read/csv "../data/fev.csv"))

(df-describe d)
