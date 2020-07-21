;;; lonely-brace-mode.el --- Inserts a newline to leave the opening brace by itself (for C# style blocks) -*- lexical-binding:t -*-

;; Copyright (C) 2020 Leonardo Dagnino

;; Author: Leonardo Schripsema
;; Created: 2020-06-21
;; Version: 0.1.0
;; Keywords: brace, block, newline
;; URL: https://github.com/leodag/lonely-brace-mode

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Lonely braces are C# style block openings: opening braces are
;; left by themselves at a line.

;; When `lonely-brace-mode' is enabled, make opening braces
;; lonely when inserting a newline between braces with nothing
;; else between them.

;;; Code:

(defun lonely-brace--open ()
  "If the opening brace is not already lonely, returns the
distance to the brace which should be made lonely.  Expects a
single `backward-char' to move to the end of the previous line."
  (save-excursion
    (backward-char 1)
    (let ((skip (skip-syntax-backward " ")))
      (if (and (eq (char-before) ?{)
               (progn
                 (backward-char 1)
                 (skip-syntax-backward " ")
                 (not (bolp))))
          (1- skip)))))

(defun lonely-brace--close ()
  "Returns the distance to the closing brace if it is the first
character after whitespace."
  (save-excursion
    (let ((skip (skip-syntax-forward " ")))
      (if (eq (char-after) ?})
          skip))))

(defun lonely-brace-post-self-insert-function ()
  "Enter a newline before the brace which should be made lonely,
and deletes whitespace between the braces. Electric-indent-mode
should do the rest of the work for us."
  (when (eq last-command-event ?\n)
    (save-excursion
      (let ((close-offset (lonely-brace--close))
            (open-offset (lonely-brace--open)))
        (when (and open-offset
                   close-offset)
          (delete-char close-offset)
          (backward-char)
          (delete-char (1+ open-offset))
          (backward-char)
          (newline 1 t))))))

;;;###autoload
(define-minor-mode lonely-brace-mode
  "When inside a pair of braces with only whitespace inside it,
  pressing enter will ensure the opening brace is by itself on a
  line. You probably want to use this together with
  `electric-pair-mode' and `electric-indent-mode'."
  :group nil
  (cond
   (lonely-brace-mode
    ;; Negative depth so it runs before the global hooks
    ;; Most importantly, before electric-pair-post-self-insert
    (add-hook 'post-self-insert-hook 'lonely-brace-post-self-insert-function -30 t))
   (t
    (remove-hook 'post-self-insert-hook 'lonely-brace-post-self-insert-function t))))

(provide 'lonely-brace-mode)

;;; lonely-brace-mode.el ends here
