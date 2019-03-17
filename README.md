# Routy
HTTP router for Racket 

Routy is a lightweight high performance HTTP request router for Racket.  
It uses the same routing syntax as used by popular Ruby web frameworks like Ruby on Rails and Sinatra.

## Usage
```racket
(require routy)
(require web-server/servlet)

(routy/get "/blog/:name/page/:page" ; eg. "/blog/racket/page/2"
  (lambda (req params)
    (format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))

;start server
(serve/servlet
    (λ (req) (routy/response req)) ; routy response
    #:launch-browser? #f
    #:servlet-path "/"
    #:port 8000
    #:servlet-regexp #rx"")

```

with wildcards
```racket
(routy/get "/blog/some*/page/:page" ; eg. "/blog/some-racket/page/2"
  (lambda (req params) 
    (format "page:~a" (request/param params 'page))))

(routy/get "/blog/*/page/:page" ; eg. "/blog/anyname/page/2" 
  (lambda (req params) 
    (format "page:~a" (request/param params 'page))))

(routy/get "/blog/**/page/:page" ; eg. "/blog/racket/super/buper/page/2"
  (lambda (req params) 
    (format "page:~a" (request/param params 'page))))
```

with params constraints:
```racket

(routy/get "/blog/:name/page/:page" #:constraints '((name #px"\\w+") (page #px"\\d+")) ; eg. "/blog/racket/page/2", but not "/blog/10/page/two"
  (lambda (req params) 
    (format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))
```

