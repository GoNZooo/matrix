#lang racket/base

(require db
         
         "db-interface.rkt"
         "messages.rkt"
         "state.rkt"
         "room-structs.rkt")

(provide jsexpr->room)
(define (jsexpr->room js)
  (room (room/room-id js)
        (room/membership js)
        (room/visibility js)
        (map jsexpr->state
             (room/states js))
        (room/messages js)))

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

(provide db/write/rooms)
(define (db/write/rooms rooms)
  (for-each
    db/write/room
    rooms))

(define (db-row->room row)
  (room (vector-ref row 0)
        (vector-ref row 1)
        (vector-ref row 2)
        '()
        '()))

(provide db/read/rooms)
(define (db/read/rooms)
  (map db-row->room
       (call-with-transaction
         db-conn
         (lambda ()
           (query-rows db-conn
                       "SELECT * FROM rooms")))))

(define (db/read/room/id room-id)
  (call-with-transaction
    db-conn
    (lambda ()
      (query-maybe-row db-conn
                       "SELECT * FROM rooms WHERE room_id = $1"
                       room-id))))

(provide room/room-id)
(define (room/room-id js)
  (hash-ref js 'room_id #f))

(provide room/membership)
(define (room/membership js)
  (hash-ref js 'membership #f))

(provide room/messages)
(define (room/messages js)
  (jsexpr->messages (hash-ref js 'messages #f)))

(provide room/states)
(define (room/states js)
  (hash-ref js 'state #f))

(provide room/visibility)
(define (room/visibility js)
  (hash-ref js 'visibility #f))

(module+ main
  (require racket/pretty)

  (pretty-print
    (set/state/room/id (room-room-id (car (db/read/rooms)))
                       "m.room.dictator"
                       '#hash((dictator . "gonz")))))

