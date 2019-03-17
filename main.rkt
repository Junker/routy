#lang racket

(require web-server/servlet
         racket-route-match
         "response.rkt")
    
(provide routy/get
         routy/post
         routy/delete
         routy/put
         routy/patch
         routy/not-found
         routy/files
         request/param
         response/make
         response/not-found
         routy/response)

(struct handler (route proc))

; Request handlers
(define handlers (make-hash '((get . ()) (post . ()) (put . ()) (delete . ()) (patch . ()))))

(define not-found-proc (λ (req) "Page not found"))

; Add request handler
(define/contract (routy/handler method path proc #:constraints constraints)
    (symbol? string? procedure? #:constraints (listof pair?) . -> . any/c) ;contract

     (unless (= (procedure-arity proc) 2)
        (raise-argument-error 'raise-argument-error "routy/handler: request handler procedure must have 2 arguments (request params)" proc))

    (hash-set! handlers 
        method 
        (append (hash-ref handlers method) (list (handler (route-compile path constraints) proc)))))

; GET request handler
(define (routy/get path proc #:constraints [constraints '()])
    (routy/handler 'get path proc #:constraints constraints))

; POST request handler
(define (routy/post path proc #:constraints [constraints '()])
    (routy/handler 'post path proc #:constraints constraints))

; PUT request handler
(define (routy/put path proc #:constraints [constraints '()])
    (routy/handler 'put path proc #:constraints constraints))

; DELETE request handler
(define (routy/delete path proc #:constraints [constraints '()])
    (routy/handler 'delete path proc #:constraints constraints))

; PATCH request handler
(define (routy/patch path proc #:constraints [constraints '()])
    (routy/handler 'patch path proc #:constraints constraints))

; Get request parameter
(define/contract (request/param params name)
    (list? symbol? . -> . string?)
    (cdr (assoc name params)))


; 404 handler
(define/contract (routy/not-found content)
    ((or/c string? procedure?) . -> . any/c) ;contract
    (cond 
        [(string? content) (set! not-found-proc (λ (req) (content)))]
        [(procedure? content) (set! not-found-proc content)]))

; files handler
(define/contract (routy/files path #:root [root (current-directory)])
    ((path-string?) (#:root path-string?) . ->* . any/c) ;contract

    (routy/get (string-append (string-trim path "/") "/**") (λ (req params)
        (let ([fullpath (build-path root (path->relative-path (simplify-path (url->path (request-uri req)))))])
            (if (file-exists? fullpath)
                (response/output (λ (op) (copy-port (open-input-file fullpath) op)) 
                    #:mime-type TEXT/HTML-MIME-TYPE)
                (response/not-found-internal req))))))

; Makes response
(define/contract (routy/response req)
    (request? . -> . response?) ; contract

    (let ([handler-keys (find-handler req)])
        (case handler-keys
            [(#f) (response/not-found-internal req)]
            [else
                (let ([handler (first handler-keys)]
                      [keys (second handler-keys)])
                            (let* ([proc (handler-proc handler)]
                                   [route (handler-route handler)]
                                   [resp (proc req keys)])
                                (if (response? resp)
                                    resp
                                    (response/make resp))))])))

;; PRIVATE

(define (response/not-found-internal req)
    (let ([content (not-found-proc req)])
        (if (response? content)
            content
            (response/not-found content))))

; Find handler 
(define (find-handler req)
    (let* ([method
                (case (request-method req)
                    [(#"GET") 'get]
                    [(#"POST") 'post]
                    [(#"PUT") 'put]
                    [(#"DELETE") 'delete]
                    [(#"PATCH") 'patch])]
           [method-handlers
               (hash-ref handlers method)])
        (for/or ([handler method-handlers]) 
            (let ([keys (route-match (handler-route handler) (request-uri req))])
                (if keys (list handler keys) #f)))))


; Convert path to relative path
(define (path->relative-path path) ;; path-string? -> path-string?
    (if (absolute-path? path)
        (apply build-path (cdr (explode-path path))) ;remove leading /
        path))

