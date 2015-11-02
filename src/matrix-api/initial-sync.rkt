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
         "room.rkt"
         "messages.rkt"
         "presence.rkt"
         "events.rkt")

(define user-info (get/user-info))

(define (get/initial-sync #:token
                          [token (user-info/access-token user-info)]
                          #:host [host credentials/host]
                          #:port [port credentials/port]
                          #:limit [limit "1"]
                          #:auto-state-update [state-update? #t])
  (define-values (response headers input-port)
    (http-sendrecv host
                   (string-append url/initial-sync
                                  "?"
                                  (format "access_token=~a&limit=~a"
                                          token limit))
                   #:port port
                   #:ssl? #t
                   #:method "GET"))

  (define sync-data (jsexpr->initial-sync (read-json input-port)))
  (when state-update?
    (db/set/end (initial-sync-end sync-data)))
  sync-data)

(struct initial-sync (end rooms presences receipts)
        #:transparent)

(provide jsexpr->initial-sync)
(define (jsexpr->initial-sync js)
  (initial-sync (initial-sync/end js)
                (map jsexpr->room
                     (initial-sync/rooms js))
                (map jsexpr->presence
                     (initial-sync/presences js))
                (initial-sync/receipts js)))

(provide initial-sync/presences)
(define (initial-sync/presences js)
  (hash-ref js 'presence #f))

(provide initial-sync/rooms)
(define (initial-sync/rooms js)
  (hash-ref js 'rooms #f))

(provide initial-sync/end)
(define (initial-sync/end js)
  (hash-ref js 'end #f))

(provide initial-sync/receipts)
(define (initial-sync/receipts js)
  (hash-ref js 'receipts #f))

(module+ main
  (require racket/pretty)
  (pretty-print
    (get/initial-sync #:limit 10)))
