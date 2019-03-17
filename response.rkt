#lang racket

(require web-server/servlet)

(provide response/make
         response/not-found)

; Make response
(define (response/make content 
    #:code [code 200]
    #:message [message #"OK"]
    #:seconds [seconds (current-seconds)]
    #:mime-type [mime-type TEXT/HTML-MIME-TYPE]
    #:headers [headers (list (make-header #"Cache-Control" #"no-cache"))])

    (response/full code
        message
        seconds
        mime-type
        headers
        (list (string->bytes/utf-8 content))))

; 404 Response
(define/contract (response/not-found [content "Page not found"])
    (() (string?)  . ->* . response?)
    (response/make #:code 404 content))

