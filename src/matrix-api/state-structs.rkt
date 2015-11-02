#lang racket/base

(provide (struct-out state))
(struct state (type age user-id room-id content event-id origin-server-ts
                    state-key)
        #:transparent)

(provide (struct-out content/join-rules))
(struct content/join-rules (join-rule)
        #:transparent)

(provide (struct-out content/room-member))
(struct content/room-member (avatar-url displayname membership replaces-state)
        #:transparent)

(provide (struct-out content/room-name))
(struct content/room-name (name)
        #:transparent)

(provide (struct-out content/history-visibility))
(struct content/history-visibility (history-availability)
        #:transparent)

(provide (struct-out content/room-create))
(struct content/room-create (creator)
        #:transparent)

(provide (struct-out content/room-topic))
(struct content/room-topic (topic)
        #:transparent)

(provide (struct-out content/room-aliases))
(struct content/room-aliases (aliases)
        #:transparent)
