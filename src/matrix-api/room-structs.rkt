#lang racket/base

(provide (struct-out room))
(struct room (room-id membership visibility states messages)
        #:transparent)
