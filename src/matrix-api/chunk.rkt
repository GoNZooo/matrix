#lang racket/base

(require
  (only-in "state-structs.rkt"
           content/room-member)
  (only-in "state.rkt"
           [state/content/room-member/avatar-url
             chunk/content/room-member/avatar-url] 
           [state/content/room-member/displayname
             chunk/content/room-member/displayname]
           [state/content/room-member/membership
             chunk/content/room-member/membership]
           [state/content/room-member/replaces-state
             chunk/content/room-member/replaces-state]))

(provide (struct-out chunk))
(struct chunk (type user-id age event-id origin-server-ts room-id state-key
                    content prev-content replaces-state)
        #:transparent)

(provide (struct-out content/room-message))
(struct content/room-message (body msgtype)
        #:transparent)

(provide (struct-out prev-content/room-member))
(struct prev-content/room-member (membership)
        #:transparent)

(provide jsexpr->chunk)
(define (jsexpr->chunk js)
  (chunk (chunk/type js)
         (chunk/user-id js)
         (chunk/age js)
         (chunk/event-id js)
         (chunk/origin-server-ts js)
         (chunk/room-id js)
         (chunk/state-key js)
         (chunk/content js)
         (chunk/prev-content js)
         (chunk/replaces-state js)))

(provide chunk/type)
(define (chunk/type js)
  (hash-ref js 'type #f))

(provide chunk/user-id)
(define (chunk/user-id js)
  (hash-ref js 'user_id #f))

(provide chunk/content)
(define (chunk/content js)
  (case (chunk/type js)
    [("m.room.member")
     (content/room-member
       (chunk/content/room-member/avatar-url (hash-ref js 'content #f))
       (chunk/content/room-member/displayname (hash-ref js 'content #f))
       (chunk/content/room-member/membership (hash-ref js 'content #f))
       (chunk/content/room-member/replaces-state (hash-ref js 'content #f)))]
    [("m.room.message")
     (content/room-message
       (chunk/content/room-message/body (hash-ref js 'content #f))
       (chunk/content/room-message/msgtype (hash-ref js 'content #f)))]
    [else
      (hash-ref js 'content #f)]))

(provide chunk/content/room-message/body)
(define (chunk/content/room-message/body js)
  (hash-ref js 'body #f))

(provide chunk/content/room-message/msgtype)
(define (chunk/content/room-message/msgtype js)
  (hash-ref js 'msgtype #f))

(provide chunk/content/membership)
(define (chunk/content/membership js)
  (hash-ref js 'membership))

(provide chunk/age)
(define (chunk/age js)
  (hash-ref js 'age #f))

(provide chunk/event-id)
(define (chunk/event-id js)
  (hash-ref js 'event_id #f))

(provide chunk/origin-server-ts)
(define (chunk/origin-server-ts js)
  (hash-ref js 'origin_server_ts #f))

(provide chunk/room-id)
(define (chunk/room-id js)
  (hash-ref js 'room_id #f))

(provide chunk/prev-content)
(define (chunk/prev-content js)
  (case (chunk/type js)
    [("m.room.member")
     (prev-content/room-member
       (chunk/content/room-member/membership (hash-ref js 'prev_content #f)))]
    [else (hash-ref js 'prev_content #f)]))

(provide chunk/replaces-state)
(define (chunk/replaces-state js)
  (hash-ref js 'replaces_state #f))

(provide chunk/state-key)
(define (chunk/state-key js)
  (hash-ref js 'state_key #f))

