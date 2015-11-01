#lang racket/base

(provide state/type)
(define (state/type js)
  (hash-ref js 'type #f))

(provide state/user-id)
(define (state/user-id js)
  (hash-ref js 'user_id #f))

(provide state/content)
(define (state/content js)
  (hash-ref js 'content #f))

(provide state/content/join-rules/join-rule)
(define (state/content/join-rules/join-rule js)
  (hash-ref js 'join_rule #f))

(provide state/content/room-member/avatar-url)
(define (state/content/room-member/avatar-url js)
  (hash-ref js 'avatar_url #f))

(provide state/content/room-member/displayname)
(define (state/content/room-member/displayname js)
  (hash-ref js 'displayname #f))

(provide state/content/room-member/membership)
(define (state/content/room-member/membership js)
  (hash-ref js 'membership #f))

(provide state/content/room-member/replaces-state)
(define (state/content/room-member/replaces-state js)
  (hash-ref js 'replaces_state #f))

(provide state/content/room-name/name)
(define (state/content/room-name/name js)
  (hash-ref js 'name #f))

(provide state/content/room-history-availability/history-availability)
(define (state/content/room-history-availability/history-availability js)
  (hash-ref js 'history_availabiliy #f))

(provide state/content/room-create/creator)
(define (state/content/room-create/creator js)
  (hash-ref js 'creator #f))

(provide state/content/room-topic/topic)
(define (state/content/room-topic/topic js)
  (hash-ref js 'topic #f))

(provide state/age)
(define (state/age js)
  (hash-ref js 'age #f))

(provide state/event-id)
(define (state/event-id js)
  (hash-ref js 'event_id #f))

(provide state/origin-server-ts)
(define (state/origin-server-ts js)
  (hash-ref js 'origin_server_ts #f))

(provide state/room-id)
(define (state/room-id js)
  (hash-ref js 'room_id #f))

(provide state/state-key)
(define (state/state-key js)
  (hash-ref js 'state_key #f))


