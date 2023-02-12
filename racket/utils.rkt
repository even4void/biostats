#lang racket

;; TODO
;; - [ ] (define (summarize response grouping fun) ...)
;; - [-] (define (recode xs) ...)
;; - [ ] (define (relevel xs levels) ...)

(define (tabulate xs)
  (for/fold ((hash #hash()))
            ((key (in-list xs)))
    (hash-update hash key add1 0)))

(define zip
  (lambda (x y) (map list x y)))

;; FIXME: needs to start from 1 since tabulate returns counts as values
(define (recode xs)
  (let* [(hash (tabulate xs))]
    ;; (labels (sort (hash-keys hash) string<?))
    ;; (levels (range 1 (add1 (length labels))))
    (for/list ([x xs])
      (hash-ref hash x))))

(provide recode)
