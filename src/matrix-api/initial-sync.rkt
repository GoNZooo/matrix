#lang racket/base

(require net/http-client
         net/url
         net/uri-codec
         json
         db

         "credentials.rkt"
         "db-interface.rkt"
         "urls.rkt"
         "login.rkt"
         "room.rkt")

(define user-info (get/user-info))

(define (get/initial-sync #:token
                          [token (user-info/access-token user-info)]
                          #:host [host credentials/host]
                          #:port [port credentials/port]
                          #:limit [limit "1"]
                          #:cache [cache? #t])
  (define-values (response headers input-port)
    (http-sendrecv host
                   (string-append url/initial-sync
                                  "?"
                                  (format "access_token=~a&limit=~a"
                                          token limit))
                   #:port port
                   #:ssl? #t
                   #:method "GET"))

  (read-json input-port))

(provide initial-sync/presences)
(define (initial-sync/presences js)
  (hash-ref js 'presence #f))

(provide initial-sync/rooms)
(define (initial-sync/rooms js)
  (hash-ref js 'rooms #f))

(define (db/write/rooms rooms)
  (for-each
    (lambda (room)
      (call-with-transaction
        db-conn
        (lambda ()
          (query-exec
            db-conn
            "REPLACE INTO rooms values ($1,$2,$3)"
            (room/room-id room)
            (room/membership room)
            (room/visibility room)))
        #:option 'immediate
        #:isolation 'read-uncommitted))
    rooms))

(provide initial-sync/end)
(define (initial-sync/end js)
  (hash-ref js 'end #f))

(provide initial-sync/receipts)
(define (initial-sync/receipts js)
  (hash-ref js 'receipts #f))

(module+ main
  (require racket/pretty)
  (pretty-print
    (db/write/rooms (initial-sync/rooms (get/initial-sync #:limit 2)))))
