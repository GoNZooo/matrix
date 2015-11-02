#lang racket/base

(require net/http-client
         net/url
         net/uri-codec
         json

         "credentials.rkt"
         "urls.rkt"
         "login.rkt")

(define (put/room/alias/id room-id alias
                           #:token
                           [token (user-info/access-token (get/user-info))])
  (define-values
    (response headers input-port)
    (http-sendrecv credentials/host
                   (format (string-append url/add/alias
                                          "?access_token=~a")
                           alias
                           token)
                   #:port credentials/port
                   #:ssl? #t
                   #:method "PUT"
                   #:data
                   (jsexpr->string
                     `#hash((room_id . ,room-id)))
                   #:headers
                   (list
                     "Content-Type: application/x-www-form-urlencoded")))
  (read-json input-port))

(module+ main
  (require "room.rkt")

  (define rooms (db/read/rooms))
  (put/room/alias/id (room-room-id (car rooms))
                     "#api-test:severnatazvezda.com"))
