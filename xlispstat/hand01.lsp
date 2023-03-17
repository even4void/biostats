(dribble "hand01.log")

;; genotype data
(def data (read-data-columns "../data/polymorphism.dat"))
(def age (select data 0))
(def genotype (select data 1))

(histogram age)

(dolist (n (iseq 1 3))
    (set (intern (concatenate 'string "GENO"
                              (write-to-string n)))
         (select age (which (= n genotype)))))

(boxplot (list geno1 geno2 geno3))

(require "oneway") ;; better than "oneway" default module

(def m (oneway-model (list geno1 geno2 geno3) :print nil))
(send m :display)
(send m :all-paired-comparisons)
(send m :individual-ci)
(send m :boxplots)

(undef (variables))

;; ToothGrowth data
(def data (read-data-columns "../data/toothgrowth.dat"))
(def len (select data 0))
(def supp (select data 1))
(def dose (select data 2))

(def x1 (select dose (which (= 1 supp))))
(def y1 (select len (which (= 1 supp))))
(def x2 (select dose (which (= 2 supp))))
(def y2 (select len (which (= 2 supp))))

(setf p (plot-points x1 y1))
(send p :point-symbol (iseq (length y1)) 'diamond)
(send p :add-points (list x2 y2))
(send p :redraw)

(dribble)
