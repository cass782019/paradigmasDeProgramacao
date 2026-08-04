#lang racket
;; =====================================================================
;;  Paradigmas de Programação - Aula 1
;;  Linguagem: Racket        Plataforma online: https://try-racket.org
;;                           ou DrRacket local, ou Replit (template Racket)
;;  Racket é a linguagem dos interpretadores (Aula 6) e das macros (Aula 16).
;; =====================================================================

(define DADOS (range 1 200001))
(define ESPERADO (for/sum ([x DADOS] #:when (even? x)) (* x x)))

;; --- 1. FUNCIONAL: composição de transformações, zero mutação --------
(define (funcional nums)
  (foldl + 0 (map (lambda (x) (* x x)) (filter even? nums))))

;; --- 2. RECURSIVO DE CAUDA: o laço do mundo funcional ---------------
(define (recursivo nums)
  (let laco ([xs nums] [acc 0])
    (cond [(null? xs) acc]
          [(even? (car xs)) (laco (cdr xs) (+ acc (* (car xs) (car xs))))]
          [else (laco (cdr xs) acc)])))

;; --- 3. IMPERATIVO: Racket também tem estado, se você insistir -------
(define (imperativo nums)
  (define total 0)                       ; caixa mutável
  (for ([x nums])
    (when (even? x) (set! total (+ total (* x x)))))
  total)

;; --- 4. OBJETO FEITO DE CLOSURE: prévia da Aula 11 -------------------
;; Um "objeto" é apenas uma função que despacha mensagens sobre um
;; ambiente capturado. Nenhuma palavra-chave class foi usada.
(define (novo-somador)
  (define total 0)
  (lambda (msg . args)
    (case msg
      [(oferecer) (let ([x (car args)])
                    (when (even? x) (set! total (+ total (* x x)))))]
      [(total) total]
      [else (error "mensagem desconhecida:" msg)])))

(define (orientado-a-objetos nums)
  (define s (novo-somador))
  (for ([x nums]) (s 'oferecer x))
  (s 'total))

;; --- Medição e gráfico em ASCII --------------------------------------
(define (cronometrar f nums)
  (define t0 (current-inexact-milliseconds))
  (define r (f nums))
  (define dt (- (current-inexact-milliseconds) t0))
  (unless (= r ESPERADO) (error "resultado divergente!"))
  dt)

(define (barra valor pico [largura 40])
  (make-string (max 1 (inexact->exact (round (* (/ valor pico) largura)))) #\#))

(define estilos (list (cons "Funcional" funcional)
                      (cons "Recursivo de cauda" recursivo)
                      (cons "Imperativo (set!)" imperativo)
                      (cons "Objeto via closure" orientado-a-objetos)))

(printf "==============================================================\n")
(printf "  PARADIGMAS DE PROGRAMACAO - AULA 1 - Racket\n")
(printf "  Problema: somar os quadrados dos pares de 1 a 200.000\n")
(printf "==============================================================\n")
(printf "  Resultado esperado: ~a\n\n" ESPERADO)

(define medidas (for/list ([e estilos]) (cons (car e) (cronometrar (cdr e) DADOS))))
(define pico (apply max (map cdr medidas)))

(printf "  TEMPO DE EXECUCAO\n")
(for ([m medidas])
  (printf "  ~a ~a ms  ~a\n"
          (~a (car m) #:min-width 20)
          (~r (cdr m) #:precision 1 #:min-width 7)
          (barra (cdr m) pico)))

(printf "\n  Os quatro devolvem o MESMO numero.\n")
(printf "  Repare no 4o: um objeto sem 'class', so com closure (Aula 11).\n")
(printf "\n  >>> AMBIENTE RACKET OK <<<\n")
