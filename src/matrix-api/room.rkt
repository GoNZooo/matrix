#lang racket/base

(require net/http-client
         net/uri-codec
         json
         db

         "db-interface.rkt"
         "credentials.rkt"
         "urls.rkt"
         "login.rkt"
         "messages.rkt"
         "state.rkt")

(provide db/write/room)
(define (db/write/room room)
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

(provide room/room-id)
(define (room/room-id js)
  (hash-ref js 'room_id #f))

(provide room/membership)
(define (room/membership js)
  (hash-ref js 'membership #f))

(provide room/messages)
(define (room/messages js)
  (hash-ref js 'messages #f))

(provide room/states)
(define (room/states js)
  (hash-ref js 'state #f))

(provide room/visibility)
(define (room/visibility js)
  (hash-ref js 'visibility #f))

(provide room/join/id)
(define (room/join/id room-id
                      #:access-token
                      [token (user-info/access-token (get/user-info))])
  (define-values
    (response headers input-port)
    (http-sendrecv credentials/host
                   (format (string-append url/join/room/id
                                          "?access_token=~a")
                           room-id token)
                   #:port credentials/port
                   #:ssl? #t
                   #:method "POST"
                   #:data
                   (jsexpr->string `#hash((room_id . ,room-id)))
                   #:headers
                   (list
                     "Content-Type: application/x-www-form-urlencoded")))
  (read-json input-port))

(provide room/create/private)
(define (room/create/private users
                             room-name
                             #:access-token
                             [token (user-info/access-token (get/user-info))])
  (define-values
    (response headers input-port)
    (http-sendrecv credentials/host
                   (format (string-append url/create/room
                                          "?access_token=~a")
                           token)
                   #:port credentials/port
                   #:ssl? #t
                   #:method "POST"
                   #:data
                   (jsexpr->string `#hash((preset . "private_chat")
                                          (name . ,room-name)
                                          (invite . ,users)))
                   #:headers
                   (list
                     "Content-Type: application/x-www-form-urlencoded")))
  (read-json input-port))
