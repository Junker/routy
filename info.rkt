#lang info

(define collection "routy")
(define version "0.0.1")
(define deps '("base" "rackunit-lib"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/routy.scrbl" ())))
(define pkg-authors '(junker))
(define pkg-desc "Routy is a lightweight high performance HTTP request router for Racket")
