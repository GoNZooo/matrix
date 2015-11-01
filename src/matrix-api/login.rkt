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

(define cache/path/user-info "cache/user/info.cache")

(define (cache/read/user-info [path cache/path/user-info])
  (call-with-input-file path
                        read))

(define (cache/write/user-info data [path cache/path/user-info])
  (call-with-output-file path
                         (lambda (out)
                           (write data out))
                         #:exists 'replace))

(provide user-info/access-token)
(define (user-info/access-token js)
  (hash-ref js 'access_token #f))

(provide user-info/home-server)
(define (user-info/home-server js)
  (hash-ref js 'home_server #f))

(provide user-info/user-id)
(define (user-info/user-id js)
  (hash-ref js 'user_id #f))

(define (make-connection host port data)
  (http-sendrecv host url/login #:port port #:ssl? #t #:method "POST"
                 #:data data
                 #:headers
                 (list
                   "Content-Type: application/x-www-form-urlencoded")))

(define (cached?/user-info)
  (file-exists? cache/path/user-info))

(provide get/user-info)
(define (get/user-info #:user [user credentials/username]
                       #:password [password credentials/password]
                       #:host [host credentials/host]
                       #:port [port credentials/port]
                       #:cache [cache? #t])
  (if (and cache?
           (cached?/user-info))
    (cache/read/user-info)
    (let*-values ([(response headers input-port)
                   (make-connection host
                                    port
                                    (jsexpr->string
                                      `#hash((type . "m.login.password")
                                             (user . ,user)
                                             (password . ,password))))]
                  [(data) (read-json input-port)])
      (cache/write/user-info data)
      data)))

(module+ main
  (get/user-info))
