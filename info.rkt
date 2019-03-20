#lang info

(define collection "routy")
(define version "0.1.2")
(define deps '("base" "web-server-lib" "rackunit-lib" "racket-route-match" "response-ext"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib" "web-server-doc"))
(define scribblings '(("scribblings/routy.scrbl" ())))
(define pkg-authors '(junker))
(define pkg-desc "Routy is a lightweight high performance HTTP request router for Racket")
