#lang racket

(require rackunit
		 web-server/servlet
		 "main.rkt")

(test-case "main"
	(check-true (response?  
		(response/not-found "NO PAGE")))

	(check-true (response?  
		(response/make "SOME TEXT")))

	(check-true (void?  
		(routy/get "/blog/:name/page/:page"
				(lambda (req params) 
				(format "blog:~a page:~a" (request/param params 'name) (request/param params 'page))))))

	(check-true (void?  
		(routy/get "/blog/:name/page/:page" #:constraints '((page #px"\\d+"))
				(lambda (req params) 
				(format "blog:~a page:~a" (request/param params 'name) (request/param params 'page)))))))