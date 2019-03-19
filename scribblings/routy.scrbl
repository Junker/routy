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
                    [proc (-> (or/c response? string?))]
                    [#:constraints (listof pair?) '()]) response?]{

handle GET request
path - path pattern. eg. "/blog/some*/page/:page"
proc - procedure takes 2 arguments: (req params) 
       req (request?)- HTTP request
       params (listof pair?) - requestr params, should be used with request/param
       returns string or response

@racketblock[
 (routy/get "/blog/:name/page/:page" ; eg. "/blog/racket/page/2"
   (lambda (req params)
     (format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))]
}

@defproc[(routy/post [path string?]
                     [proc (-> (request? (listof pair?)) (or/c response? string?))]
                     [#:constraints (listof pair?) '()]) void?]{

handle POST request
}

@defproc[(routy/put [path string?]
                    [proc (-> (or/c response? string?))]
                    [#:constraints (listof pair?) '()]) void?]{

handle PUT request
}

@defproc[(routy/patch [path string?]
                      [proc (-> (or/c response? string?))]
                      [#:constraints (listof pair?) '()]) void?]{

handle PATCH request
}

@defproc[(routy/delete [path string?]
                       [proc (-> (or/c response? string?))]
                       [#:constraints (listof pair?) '()]) void?]{

handle DELETE request
}


@defproc[(routy/files [path path-string?]
                      [#:root string? (current-directory)]) void?]{

serve files
}

@defproc[(routy/not-found [content (or/c string? procedure?)]) void?]{

Not found route
}

@defproc[(routy/response [req request?]) response?]{

Handle web-server requests.

@racketblock[
(serve/servlet
    (λ (req) (routy/response req)) ; routy response
    #:launch-browser? #f
    #:servlet-path "/"
    #:port 8000
    #:servlet-regexp #rx"")]
}


Example of usage:

@racketblock[
(require routy)
(require web-server/servlet)
(require response-ext)

(routy/get "/blog/:name/page/:page" ; eg. "/blog/racket/page/2"
  (lambda (req params)
    (format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))

(routy/get "/product/:id" ; eg. "/product/34"
  (lambda (req params)
    (response/not-found)))

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
