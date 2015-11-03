#lang racket/base

(require "matrix-api/initial-sync.rkt"
         "matrix-api/room.rkt")

(define )

(define dispatch-hash/type
  `#hash(("m.room.message" . ,m.room.message-handler)))

(module+ main
  (define init-sync (get/initial-sync)))
