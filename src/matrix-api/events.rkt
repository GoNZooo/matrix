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

(provide event/content)
(define (event/content event)
  (hash-ref event 'content #f))

(provide event/type)
(define (event/type event)
  (hash-ref event 'type #f))

(provide event/event-id)
(define (event/event-id event)
  (hash-ref event 'event_id #f))

(provide event/room-id)
(define (event/room-id event)
  (hash-ref event 'room_id #f))

(provide event/user-id)
(define (event/user-id event)
  (hash-ref event 'user_id #f))

(provide event/prev-content)
(define (event/prev-content event)
  (hash-ref event 'prev_content #f))

(provide event/state-key)
(define (event/state-key event)
  (hash-ref event 'state_key #f))

(provide event/age)
(define (event/age js)
  (hash-ref js 'age #f))

(provide event/origin-server-ts)
(define (event/origin-server-ts js)
  (hash-ref js 'origin_server_ts #f))

(provide get/events)
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

