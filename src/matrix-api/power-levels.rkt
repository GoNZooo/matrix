#lang racket/base

(provide (struct-out content/power-levels))
(struct content/power-levels (ban events events-default invite kick redact
                                  state-default users users-default)
        #:transparent)

(provide (struct-out power-level/user))
(struct power-level/user (id power-level)
        #:transparent)

(provide jsexpr->content/power-levels)
(define (jsexpr->content/power-levels js)
  (content/power-levels (power-levels/ban js)
                        (power-levels/events js)
                        (power-levels/events-default js)
                        (power-levels/invite js)
                        (power-levels/kick js)
                        (power-levels/redact js)
                        (power-levels/state-default js)
                        (for/list ([(key val) (power-levels/users js)])
                          (power-level/user key val))
                        (power-levels/users-default js)))

(provide power-levels/ban)
(define (power-levels/ban js)
  (hash-ref js 'ban #f))

(provide power-levels/events)
(define (power-levels/events js)
  (hash-ref js 'events #f))

(provide power-levels/events/room-avatar)
(define (power-levels/events/room-avatar js)
  (hash-ref js 'm.room.avatar #f))

(provide power-levels/events/room-canonical-alias)
(define (power-levels/events/room-canonical-alias js)
  (hash-ref js 'm.room.canonical_alias #f))

(provide power-levels/events/history-visibility)
(define (power-levels/events/history-visibility js)
  (hash-ref js 'm.room.history_visibility #f))

(provide power-levels/events/room-name)
(define (power-levels/events/room-name js)
  (hash-ref js 'm.room.name #f))

(provide power-levels/events/power-levels)
(define (power-levels/events/power-levels js)
  (hash-ref js 'm.room.power_levels #f))

(provide power-levels/events-default)
(define (power-levels/events-default js)
  (hash-ref js 'events_default #f))

(provide power-levels/invite)
(define (power-levels/invite js)
  (hash-ref js 'invite #f))

(provide power-levels/kick)
(define (power-levels/kick js)
  (hash-ref js 'kick #f))

(provide power-levels/redact)
(define (power-levels/redact js)
  (hash-ref js 'redact #f))

(provide power-levels/state-default)
(define (power-levels/state-default js)
  (hash-ref js 'state_default #f))

(provide power-levels/users)
(define (power-levels/users js)
  (hash-ref js 'users #f))

(provide power-levels/users-default)
(define (power-levels/users-default js)
  (hash-ref js 'users_default #f))

