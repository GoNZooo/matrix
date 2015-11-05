#lang racket/base

(require gregor)

(provide parse/absolute/se)
(define (parse/absolute/se datetime-string)
  (parse-datetime datetime-string "yyyy-MM-dd HH:mm"))

(provide parse/absolute/bg)
(define (parse/absolute/bg datetime-string)
  (parse-datetime datetime-string "dd.MM.yy HH:mm"))

