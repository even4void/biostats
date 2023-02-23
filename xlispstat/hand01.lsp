
(def *data* (read-data-columns "../data/toothgrowth.dat"))
(def len (select *data* 0))
(def supp (select *data* 1))
(def dose (select *data* 2))
