#lang racket/base

(require net/http-client
         net/url
         net/uri-codec
         json

         "credentials.rkt"
         "urls.rkt")

(define (login/types #:host [host credentials/host]
                     #:port [port credentials/port])
  (define-values (response headers input-port)
    (http-sendrecv host
                   url/login
                   #:port port
                   #:ssl? #t
                   #:method "GET"))
  (read-json input-port))
  

(provide login/access-token)
(define (login/access-token #:user [user credentials/username]
                            #:password [password credentials/password]
                            #:host [host credentials/host]
                            #:port [port credentials/port])
  (define-values (response headers input-port)
    (http-sendrecv host
                   url/login
                   #:port port
                   #:ssl? #t
                   #:method "POST"
                   #:data
                   (jsexpr->string
                     `#hash((type . "m.login.password")
                            (user . ,user)
                            (password . ,password)))
                   #:headers
                   (list "Content-Type: application/x-www-form-urlencoded")))

  (read-json input-port))

(module+ main
  (login/access-token))
