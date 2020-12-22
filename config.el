;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Diogo Valério"
      user-mail-address "diogocsvalerio@protonmail.com")

(setq doom-font (font-spec :family "Rec Mono Linear" :size 20)
      doom-big-font (font-spec :family "Rec Mono Linear" :size 36)
      doom-variable-pitch-font (font-spec :family "Rec Mono Linear" :size 24)
      doom-serif-font (font-spec :family "Rec Mono Linear" :weight 'light))



(setq doom-theme 'doom-gruvbox)
(delq! t custom-theme-load-path)
(setq org-directory "~/org/")
(use-package bongo
  :ensure t :defer t
  :init (progn
          (setq bongo-default-directory "/mnt/Extux/Music/"
                bongo-confirm-flush-playlist nil
                bongo-insert-whole-directory-trees 't)))
(setq display-line-numbers-type 'relative)
(after! evil-snipe
  (evil-snipe-mode -1))

(global-subword-mode 1)                           ; Iterate through CamelCase words
(setq +ivy-buffer-preview t)
(map! :map evil-window-map
      "SPC" #'rotate-layout
      ;; Navigation
      "<left>"     #'evil-window-left
      "<down>"     #'evil-window-down
      "<up>"       #'evil-window-up
      "<right>"    #'evil-window-right
      ;; Swapping windows
      "C-<left>"       #'+evil/window-move-left
      "C-<down>"       #'+evil/window-move-down
      "C-<up>"         #'+evil/window-move-up
      "C-<right>"      #'+evil/window-move-right)

(global-set-key (kbd "C-; C-;") 'xah-comment-dwim)

(setq company-idle-delay 0)
(setq gc-cons-threshold 20000000)
(setq make-backup-files nil)
(setq confirm-kill-emacs 'y-or-n-p)
(display-time-mode t)

(require 'mu4e)

(setq mu4e-root-maildir "~/extux/Mail/"
mu4e-attachment-dir "~/Downloads")

(setq user-mail-address "diogocsvalerio@protonmail.com"
user-full-name  "Diogo Valerio")

;; Get mail
(setq mu4e-get-mail-command "mbsync protonmail"
mu4e-change-filenames-when-moving t   ; needed for mbsync
mu4e-update-interval 120)             ; update every 2 minutes

;; Send mail
(setq message-send-mail-function 'smtpmail-send-it
smtpmail-auth-credentials "~/.authinfo.gpg"
smtpmail-smtp-server "127.0.0.1"
smtpmail-stream-type 'ssl
smtpmail-smtp-service 1025)
(add-to-list 'gnutls-trustfiles (expand-file-name "~/.config/protonmail/bridge/cert.pem"))

(setq org-mu4e-convert-to-html t)

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package java-mode
  :ensure t
  :commands (java-mode)
  :mode (("\\.java\\'" . java-mode)))

(defun set-exec-path-from-shell-PATH ()
  "Sets the exec-path to the same value used by the user shell"
  (let ((path-from-shell
         (replace-regexp-in-string
          "[[:space:]\n]*$" ""
          (shell-command-to-string "$SHELL -l -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

(after! org
  (require 'org-bullets)  ; Nicer bullets in org-mode
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  (setq org-directory "~/org/"
        org-agenda-files '("~/Org/agenda.org")
        org-default-notes-file (expand-file-name "notes.org" org-directory)
        org-ellipsis " ▼ "
        org-log-done 'time
        org-journal-dir "~/org/journal/"
        org-journal-date-format "%B %d, %Y (%A)"
        org-journal-file-format "%Y-%m-%d.org"
        org-hide-emphasis-markers t
        ;; ex. of org-link-abbrev-alist in action
        ;; [[arch-wiki:Name_of_Page][Description]]
        org-link-abbrev-alist    ; This overwrites the default Doom org-link-abbrev-list
          '(("google" . "http://www.google.com/search?q=")
            ("arch-wiki" . "https://wiki.archlinux.org/index.php/")
            ("ddg" . "https://duckduckgo.com/?q=")
            ("wiki" . "https://en.wikipedia.org/wiki/"))
        org-todo-keywords        ; This overwrites the default Doom org-todo-keywords
          '((sequence
             "TODO(t)"           ; A task that is ready to be tackled
             "BLOG(b)"           ; Blog writing assignments
             "GYM(g)"            ; Things to accomplish at the gym
             "PROJ(p)"           ; A project that contains other tasks
             "VIDEO(v)"          ; Video assignments
             "WAIT(w)"           ; Something is holding up this task
             "|"                 ; The pipe necessary to separate "active" states and "inactive" states
             "DONE(d)"           ; Task has been completed
             "CANCELLED(c)" )))) ; Task has been cancelled
(defun dt/org-babel-tangle-async (file)
  "Invoke `org-babel-tangle-file' asynchronously."
  (message "Tangling %s..." (buffer-file-name))
  (async-start
   (let ((args (list file)))
  `(lambda ()
        (require 'org)
        ;;(load "~/.emacs.d/init.el")
        (let ((start-time (current-time)))
          (apply #'org-babel-tangle-file ',args)
          (format "%.2f" (float-time (time-since start-time))))))
   (let ((message-string (format "Tangling %S completed after " file)))
     `(lambda (tangle-time)
        (message (concat ,message-string
                         (format "%s seconds" tangle-time)))))))

(defun dt/org-babel-tangle-current-buffer-async ()
  "Tangle current buffer asynchronously."
  (dt/org-babel-tangle-async (buffer-file-name)))
(global-set-key (kbd "M-#") 'lookup-word)

(setq org-hide-emphasis-markers 't
      org-hide-macro-markers 't)
