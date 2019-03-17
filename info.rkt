#lang info

(define collection "routy")
(define version "0.0.2")
(define deps '("base" "web-server-lib" "rackunit-lib" "response-ext"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/routy.scrbl" ())))
(define pkg-authors '(junker))
(define pkg-desc "Routy is a lightweight high performance HTTP request router for Racket")
