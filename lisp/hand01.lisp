(ql:quickload "cl-ana")
(in-package :cl-ana)

(defparameter *data* (open-csv-table "/home/chl/cwd/biostats/data/polymorphism.dat" 
				     :delimeter #\SPACE 
				     :field-names '("age" "genotype")))
(table-field-names *data*)
(table-summarize *data*)

