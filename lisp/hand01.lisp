(ql:quickload "cl-ana")
(in-package :cl-ana)

(defparameter *data* (open-csv-table "/home/chl/cwd/biostats/data/polymorphism.csv"))
(table-field-names *data*)

