#lang racket/base

(require net/http-client
         net/url
         net/uri-codec
         json

         "credentials.rkt"
         "urls.rkt"
         "login.rkt")

(provide state/type)
(define (state/type js)
  (hash-ref js 'type #f))

(provide state/user-id)
(define (state/user-id js)
  (hash-ref js 'user_id #f))

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
(define (set/state/room/id room-id event-type content
                           #:state-key [state-key #f]
                           #:access-token
                           [token (user-info/access-token (get/user-info))])
  (define-values
    (response headers input-port)
    (http-sendrecv credentials/host
                   (if (not state-key)
                       (format (string-append url/set/state/no-state-key
                                              "?access_token=~a")
                               room-id event-type token)
                       (format (string-append url/set/state/state-key
                                              "?access_token=~a")
                               room-id event-type state-key token))
                   #:port credentials/port
                   #:ssl? #t
                   #:method "PUT"
                   #:data (jsexpr->string content)
                   #:headers
                   (list
                    "Content-Type: application/x-www-form-urlencoded")))
  (read-json input-port))

(provide get/state/room/id)
(define (get/state/room/id room-id event-type
                           #:state-key [state-key ""]
                           #:access-token
                           [token (user-info/access-token (get/user-info))])
  (define-values
    (response headers input-port)
    (http-sendrecv credentials/host
                   (format (string-append url/get/state
                                          "?access_token=~a")
                           room-id event-type state-key token)
                   #:port credentials/port
                   #:ssl? #t
                   #:method "GET"))
  (read-json input-port))


