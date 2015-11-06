#lang racket/base

(require gregor
         gregor/period)

(provide parse/datetime/absolute/bg)
(define (parse/datetime/absolute/bg datetime-string)
  (parse-datetime datetime-string "dd.MM.yy HH:mm"))

(provide bg-time->sql-time)
(define (bg-time->sql-time datetime)
  (~t datetime "YYYY-MM-dd HH:mm:ss"))

