(defpackage :mona-lisa-gol-asd
  (:use :cl :asdf))

(in-package :mona-lisa-gol-asd)

(defsystem mona-lisa-gol
  :license "MIT"
  :author "Kevin Galligan"
  :depends-on (:sketch :alexandria :png-read :skippy :cl-sat.minisat)
  :pathname "src"
  :serial t
  :components ((:file "package")
               (:file "game-of-life")
               (:file "backsearch")
               (:file "gif")
               (:file "animate")))
