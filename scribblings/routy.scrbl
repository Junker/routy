#lang scribble/manual
@require[@for-label[routy
                    racket/base
                    response-ext
                    web-server/servlet]]

@title{routy}
@author{junker}

@defmodule[routy]

HTTP router for Racket 

Routy is a lightweight high performance HTTP request router for Racket.  
It uses the same routing syntax as used by popular Ruby web frameworks like Ruby on Rails and Sinatra.


@defproc[(routy/get [path string?]
                    [proc (-> (or/c response? string?))]) response?]
                    [#:constraints (listof pair?) '()]{

handle GET requests
@racketblock[
 (routy/get "/blog/:name/page/:page" ; eg. "/blog/racket/page/2"
   (lambda (req params)
     (format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))]
}

Example of usage:

@racketblock[
(require routy)
(require web-server/servlet)
(require response-ext)

(routy/get "/blog/:name/page/:page" ; eg. "/blog/racket/page/2"
  (lambda (req params)
    (format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))

(routy/post ...) ; POST request
(routy/put ...) ; PUT request
(routy/delete ...) ; DELETE request
(routy/patch ...) ; PATCH request

; start server
(serve/servlet
    (λ (req) (routy/response req)) ; routy response
    #:launch-browser? #f
    #:servlet-path "/"
    #:port 8000
    #:servlet-regexp #rx"")


; with wildcards:
(routy/get "/blog/some*/page/:page" ; eg. "/blog/some-racket/page/2"
  (lambda (req params) 
    (format "page:~a" (request/param params 'page))))

(routy/get "/blog/*/page/:page" ; eg. "/blog/anyname/page/2" 
  (lambda (req params) 
    (format "page:~a" (request/param params 'page))))

(routy/get "/blog/**/page/:page" ; eg. "/blog/racket/super/buper/page/2"
  (lambda (req params) 
    (format "page:~a" (request/param params 'page))))

; not found 404 page:
(routy/not-found 
	(lambda (req) 
		"OOPS.. CANNOT FIND THIS PAGE"))

(routy/not-found 
	"OOPS.. CANNOT FIND THIS PAGE")

(routy/not-found 
	(lambda (req)
		(response/make #:code 200 "SOME TEXT")))

;serve files:
(routy/files "/plain-docs" #:root "/var/www/my-site") ; eg. "/plain-docs/boring-doc.html"

;with params constraints:
(routy/get "/blog/:name/page/:page" #:constraints '((name #px"\\w+") (page #px"\\d+")) ; eg. "/blog/racket/page/2", but not "/blog/10/page/two"
  (lambda (req params) 
    (format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))
]
