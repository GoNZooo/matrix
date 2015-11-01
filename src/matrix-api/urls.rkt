#lang racket/base

(provide url/login)
(define url/login "/_matrix/client/api/v1/login")

(provide url/initial-sync)
(define url/initial-sync "/_matrix/client/api/v1/initialSync")

(provide url/events)
(define url/events "/_matrix/client/api/v1/events")

(provide url/send/message)
(define url/send/message "/_matrix/client/api/v1/rooms/~a/send/m.room.message")
