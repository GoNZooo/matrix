#lang racket/base

(provide url/login)
(define url/login "/_matrix/client/api/v1/login")

(provide url/initial-sync)
(define url/initial-sync "/_matrix/client/api/v1/initialSync")

(provide url/events)
(define url/events "/_matrix/client/api/v1/events")

(provide url/send/message/id)
(define url/send/message/id
  "/_matrix/client/api/v1/rooms/~a/send/m.room.message")

(provide url/add/alias)
(define url/add/alias "/_matrix/client/api/v1/directory/room/~a")

(provide url/set/state/state-key)
(define url/set/state/state-key "/_matrix/client/api/v1/rooms/~a/state/~a/~a")

(provide url/set/state/no-state-key)
(define url/set/state/no-state-key "/_matrix/client/api/v1/rooms/~a/state/~a")

(provide url/get/state)
(define url/get/state url/set/state/state-key)

(provide url/join/room/id)
(define url/join/room/id "/_matrix/client/api/v1/rooms/~a/join")
