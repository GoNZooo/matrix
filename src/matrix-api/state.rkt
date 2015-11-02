#lang racket/base

(require net/http-client
         net/url
         net/uri-codec
         json

         "credentials.rkt"
         "urls.rkt"
         "login.rkt"
         "power-levels.rkt"
         "state-structs.rkt")

(provide jsexpr->state)
(define (jsexpr->state js)
  (state (state/type js)
         (state/age js)
         (state/user-id js)
         (state/room-id js)
         (state/content js) 
         (state/event-id js)
         (state/origin-server-ts js)
         (state/state-key js)))

(provide state/type)
(define (state/type js)
  (hash-ref js 'type #f))

(provide state/user-id)
(define (state/user-id js)
  (hash-ref js 'user_id #f))

(provide state/content)
(define (state/content js)
  (case (state/type js)
    [("m.room.join_rules")
     (content/join-rules
       (state/content/join-rules/join-rule (hash-ref js 'content #f)))]
    [("m.room.member")
     (content/room-member
       (state/content/room-member/avatar-url (hash-ref js 'content #f))
       (state/content/room-member/displayname (hash-ref js 'content #f))
       (state/content/room-member/membership (hash-ref js 'content #f))
       (state/content/room-member/replaces-state (hash-ref js 'content #f)))]
    [("m.room.name")
     (content/room-name
       (state/content/room-name/name (hash-ref js 'content #f)))]
    [("m.room.create")
     (content/room-create
       (state/content/room-create/creator (hash-ref js 'content #f)))]
    [("m.room.topic")
     (content/room-topic
       (state/content/room-topic/topic (hash-ref js 'content #f)))]
    [("m.room.aliases")
     (content/room-aliases
       (state/content/room-aliases/aliases (hash-ref js 'content #f)))]
    [("m.room.power_levels")
     (jsexpr->content/power-levels (hash-ref js 'content #f))]
    [("m.room.history_visibility")
     (content/room-topic
       (state/content/history-visibility/history-visibility
         (hash-ref js 'content #f)))]
    [else (hash-ref js 'content #f)]))

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

(provide state/content/history-visibility/history-visibility)
(define (state/content/history-visibility/history-visibility js)
  (hash-ref js 'history_visibility #f))

(provide state/content/room-create/creator)
(define (state/content/room-create/creator js)
  (hash-ref js 'creator #f))

(provide state/content/room-topic/topic)
(define (state/content/room-topic/topic js)
  (hash-ref js 'topic #f))

(provide state/content/room-aliases/aliases)
(define (state/content/room-aliases/aliases js)
  (hash-ref js 'aliases #f))

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

(provide set/state/room/id)
(define (set/state/room/id room-id event content
                           #:state-key [state-key #f]
                           #:access-token
                           [token (user-info/access-token (get/user-info))])
  (define-values
    (response headers input-port)
    (http-sendrecv credentials/host
                   (if (not state-key)
                     (format (string-append url/set/state/no-state-key
                                            "?access_token=~a")
                             room-id event token)
                     (format (string-append url/set/state/no-state-key
                                            "?access_token=~a")
                             room-id event state-key token))
                   #:port credentials/port
                   #:ssl? #t
                   #:method "PUT"
                   #:data (jsexpr->string content)
                   #:headers
                   (list
                     "Content-Type: application/x-www-form-urlencoded")))
  (read-json input-port))
