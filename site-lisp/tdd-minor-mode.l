; -*- mode: lisp; package: editor -*-

;;; tdd-minor-mode.l --- TDD (Test Driven Development) support minor mode.
;;
;; Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;
;; Author: MIYAMUKO Katsuyuki <miyamuko@gmail.com>
;; Version: 0.1
;; Keywords: test, tdd
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;; Commentary:
;;
;; * 以下の Emacs Lisp を xyzzy に移植したものです。
;;
;;   TDDの勘所とTDD支援超簡易Emacs Lisp - aikeの日記
;;   http://d.hatena.ne.jp/aike/20080217
;;
;; * tdd-minor-mode を実行して、C-c m するとバッファの色が 赤→緑→オレンジ
;;   と変わります。
::
;; * color が必要なので NetInstaller (または以下) からインストールしてください。
;;   http://ohkubo.s53.xrea.com/xyzzy/index.html#outline-tree2
;;


;;; Code:

(in-package "editor")
(require "color")

(export '(*tdd-minor-mode*
          *tdd-minor-mode-hook*
          *tdd-minor-mode-change-state-hook*
          *tdd-minor-mode-state*
          *tdd-minor-mode-line*
          *tdd-minor-mode-bgcolor-alist*
          tdd-minor-mode
          ))

(defvar-local *tdd-minor-mode* nil)
(defvar-local *tdd-minor-mode-state* 0)
(defvar-local *tdd-minor-mode-line* "")

(defvar *tdd-minor-mode-hook* nil)
(defvar *tdd-minor-mode-change-state-hook* nil)
(defvar *tdd-minor-mode-bgcolor-alist*
  `(("Think"       . ("[Colors]backColor" ,*color-xyzzy-colors-name-alist*))
    ("Red"         . "#ff4444")
    ("Green"       . "#44dd44")
    ("Refactoring" . "#ffaa44")
    ))

(defvar *tdd-minor-mode-map*
  (let ((m (make-sparse-keymap)))
    (define-key m '(#\C-c #\m) 'tdd-rotate-bgcolor)
    m))

(defun tdd-color->bgr (color)
  (if (listp color)
      (apply 'color-name2code color)
    (color-rgb2bgr (color-str2code color))))

(defun tdd-buffer-colors (color)
  (make-array 2 :initial-contents (list 0 (tdd-color->bgr color))))

(defun tdd-update-bgcolor ()
  (let ((pair (nth *tdd-minor-mode-state* *tdd-minor-mode-bgcolor-alist*)))
    (set-buffer-colors (tdd-buffer-colors (cdr pair)))
    (setf *tdd-minor-mode-line* (car pair))
    (message *tdd-minor-mode-line*)
    (update-mode-line t)
    ))

(defun tdd-rotate-bgcolor ()
  (interactive)
  (setf *tdd-minor-mode-state* (mod (1+ *tdd-minor-mode-state*)
                                    (length *tdd-minor-mode-bgcolor-alist*)))
  (tdd-update-bgcolor)
  (run-hooks '*tdd-minor-mode-change-state-hook*))

(defun tdd-minor-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode '*tdd-minor-mode* arg sv)
  (setf *tdd-minor-mode-state* 0)
  (tdd-update-bgcolor)
  (if *tdd-minor-mode*
      (set-minor-mode-map *tdd-minor-mode-map*)
    (unset-minor-mode-map *tdd-minor-mode-map*))
  (run-hooks '*tdd-minor-mode-hook*))

(pushnew '(*tdd-minor-mode* . *tdd-minor-mode-line*) *minor-mode-alist* :key #'car)


(provide "tdd-minor-mode")

;;; tdd-minor-mode.l ends here
