#lang racket

(require rackunit
		 web-server/servlet
		 response-ext
		 "main.rkt")

(test-case "main"
	(check-true (response?  
		(response/not-found "NO PAGE")))

	(check-true (response?  
		(response/make "SOME TEXT")))

	(define params '((name . "racket") (page . "2")))
	(check-equal? 
		(request/param params 'name)
		"racket")

	(check-true (void?  
		(routy/get "/blog/:name/page/:page"
				(lambda (req params) 
					(format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))))

	(check-true (void?  
		(routy/post "/blog/:name/page/:page" #:constraints '((page #px"\\d+"))
				(lambda (req params) 
					(format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))))

	(check-true (void?  
		(routy/not-found 
				(lambda (req) 
					"OOPS.. CANNOT FIND THIS PAGE"))))

	(check-true (void?  
		(routy/not-found 
			"OOPS.. CANNOT FIND THIS PAGE")))

	(check-true (void?  
		(routy/not-found 
				(lambda (req) 
					(response/make #:code 200 "SOME TEXT")))))

	(check-true (void?  
		(routy/files "/my-site" #:root "/var/www"))))

	(define req (request #"GET" (string->url "/blog/racket/page/2") '() (delay '()) #f "127.0.0.1" 8000 "127.0.0.1"))

	(check-true (response?
		(routy/response req)))

	(define content-port (open-output-string)) 
	((response-output (routy/response req)) content-port)

	(check-equal?
		(get-output-string content-port)
		"blog:racket page:2")