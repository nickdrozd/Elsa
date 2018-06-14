;; An example file for analysis.  This file is *NOT* loaded, we only
;; read it and analyse statically.

(require 'dash)
(require 'elsa-types)

(elsa + :: [numeric] -> numeric)

;; elsa-type annotates any form with this type
(elsa-cast string
  (defvar foo 'lala))

(elsa foo :: string)
(defvar foo 'lala)

(elsa  use-foo :: string -> string? -> string)
(defun use-foo (foo &optional bar)
  "Return string representation of FOO."
  (declare (elsa-args string? string) ;; nullable string
           (elsa-return string))
  (symbol-name foo))

(let ((a 1)
      (b a))
  a)

;; (elsa c :: string)
(let* ((c 1)
       (d c))
  a)

;; form is checked according to the definition of use-foo and foo
;; variable
(use-foo foo "")

(use-foo "or a literal value can be provided" nil)

(use-foo 1 1) ;; fails on integer literal

(font-lock-add-keywords
 nil
 '(("(\\(elsa\\) +\\(\\(?:\\sw\\|\\s_\\)+\\) +::"
    (1 font-lock-keyword-face t)
    (2 font-lock-function-name-face t)
    ("\\_<\\(\\(?:\\sw\\|\\s_\\)+\\)\\_>"
     (save-excursion (up-list) (point))
     (progn (backward-up-list) (down-list))
     (0 font-lock-type-face t))
    ("->" (save-excursion (up-list) (point))
     nil
     (0 font-lock-variable-name-face t)))))

;; (elsa plus :: number -> number -> number)
(defun plus (a b)
  ;; (elsa x :: string)
  (let ((x something-global)))
  (+ a b))

;; (elsa :: number -> number -> number)
(defun plus (a b)
  (+ a b))


(defun plus (a b)
  (+ a b))
