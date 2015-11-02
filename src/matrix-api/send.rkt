#lang racket/base

(require net/http-client
         net/url
         net/uri-codec
         json

         "credentials.rkt"
         "urls.rkt"
         "login.rkt")

(define (send/room/message/id room-id message
                              #:token
                              [token (user-info/access-token (get/user-info))])
  (define-values
    (response headers input-port)
    (http-sendrecv credentials/host
                   (format (string-append url/send/message/id
                                          "?access_token=~a")
                           room-id
                           token)
                   #:port credentials/port
                   #:ssl? #t
                   #:method "POST"
                   #:data
                   (jsexpr->string
                     `#hash((body . ,message)
                            (msgtype . "m.text")))
                   #:headers
                   (list
                     "Content-Type: application/x-www-form-urlencoded")))
  (read-json input-port))

(module+ main
  (require "room-structs.rkt"
           "initial-sync.rkt")

  (define rooms (db/read/rooms))
  rooms
  (send/room/message/id (room-room-id (car rooms))
                        "Hejhej. :)"))
