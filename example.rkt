#lang racket

(require web-server/servlet
         web-server/servlet-env)

(require "main.rkt")

(routy/get "/blog/:name/page/:page" #:constraints '((name #px"\\w+") (page #px"\\d+"))
  (lambda (req params) 
    (format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))

(routy/not-found 
    (lambda (req)
        "I don't have this page! :'("))

(routy/files "/docs" :root "/var/www/my-site")


(serve/servlet
    (λ (req) (routy/response req))
    #:launch-browser? #f
    #:servlet-path "/"
    #:port 8000
    #:servlet-regexp #rx"")
