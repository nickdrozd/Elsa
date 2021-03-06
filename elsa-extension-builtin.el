(require 'elsa-analyser)
(require 'elsa-infer)

;; * boolean functions
(defun elsa--analyse:not (form scope state)
  (elsa--analyse-function-call form scope state)
  (let ((args (cdr (oref form sequence))))
    (let ((arg-type (oref (car args) type)))
      (cond
       ((elsa-type-accept (elsa-type-nil) arg-type) ;; definitely false
        (oset form type (elsa-type-t)))
       ((not (elsa-type-accept arg-type (elsa-type-nil))) ;; definitely true
        (oset form type (elsa-type-nil)))
       (t (oset form type (elsa-make-type T?)))))))

;; * list functions
(defun elsa--analyse:car (form scope state)
  (elsa--analyse-function-call form scope state)
  (-when-let* ((arg (cadr (oref form sequence)))
               (arg-type (oref arg type)))
    (cond
     ((elsa-type-list-p arg-type)
      (oset form type (elsa-type-make-nullable (oref arg-type item-type))))
     ((elsa-type-cons-p arg-type)
      (oset form type (oref arg-type car-type))))))

(defun elsa--analyse:cons (form scope state)
  (elsa--analyse-function-call form scope state)
  (-when-let* ((car-type (oref (nth 1 (oref form sequence)) type))
               (cdr-type (oref (nth 2 (oref form sequence)) type)))
    (oset form type (elsa-type-cons :car-type car-type :cdr-type cdr-type))))

(defun elsa--analyse:elt (form scope state)
  (elsa--analyse-function-call form scope state)
  (-when-let* ((arg (cadr (oref form sequence)))
               (arg-type (oref arg type)))
    (when (elsa-instance-of arg-type (elsa-make-type Sequence))
      (let* ((item-type (elsa-type-get-item-type arg-type))
             ;; with lists it returns nil when overflowing, otherwise
             ;; throws an error
             (item-type (if (elsa-type-list-p arg-type)
                            (elsa-type-make-nullable item-type)
                          item-type)))
        (oset form type item-type)))))

;; * predicates
(defun elsa--analyse:stringp (form scope state)
  (elsa--analyse-function-call form scope state)
  (oset form type
        (elsa--infer-unary-fn form
          (lambda (arg-type)
            (cond
             ((elsa-type-accept (elsa-type-string) arg-type)
              (elsa-type-t))
             ;; if the arg-type has string as a component, for
             ;; example int | string, then it might evaluate
             ;; sometimes to true and sometimes to false
             ((elsa-type-accept arg-type (elsa-type-string))
              (elsa-make-type T?))
             (t (elsa-type-nil)))))))

(provide 'elsa-extension-builtin)
