#lang racket/base

(require "chunk.rkt")

(provide (struct-out messages))
(struct messages (start end chunks)
        #:transparent)

(provide jsexpr->messages)
(define (jsexpr->messages js)
  (messages (message/start js)
            (message/end js)
            (message/chunks js)))

(provide message/chunks)
(define (message/chunks js)
  (map jsexpr->chunk (hash-ref js 'chunk #f)))

(provide message/start)
(define (message/start js)
  (hash-ref js 'start #f))

(provide message/end)
(define (message/end js)
  (hash-ref js 'end #f))

