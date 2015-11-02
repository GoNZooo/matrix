#lang racket/base

(require net/http-client
         net/url
         net/uri-codec
         json
         db

         "credentials.rkt"
         "urls.rkt"
         "login.rkt"
         "db-interface.rkt")

(define user-info (get/user-info))

(define (get/events #:token
                    [token (user-info/access-token user-info)]
                    #:host [host credentials/host]
                    #:port [port credentials/port]
                    #:timeout [timeout 500]
                    #:from [from (db/get/end)]
                    #:auto-state-update [state-update? #t])
  (define-values (response headers input-port)
    (http-sendrecv host
                   (string-append url/events
                                  "?"
                                  (format "access_token=~a&from=~a&timeout=~a"
                                          token from timeout))
                   #:port port
                   #:ssl? #t
                   #:method "GET"))
  (define js-data (read-json input-port))
  (when state-update?
    (db/set/end (hash-ref js-data
                          'end)))

  js-data)

(provide db/get/end)
(define (db/get/end)
  (call-with-transaction
    db-conn
    (lambda ()
      (query-maybe-value db-conn "SELECT key FROM end"))))

(provide db/set/end)
(define (db/set/end key)
  (call-with-transaction
    db-conn
    (lambda ()
      (query-exec db-conn "UPDATE end SET key = $1" key))
    #:option 'immediate))

(module+ main
  (require racket/pretty)

  (pretty-print 
    (get/events)))

