;;; mocp.el --- Managing Music On Console Player(mocp) from within Emacs

;; Author: Andreas Marschke <xxtjaxx@gmail.com>
;; Maintainer: Andreas Marschke <xxtjaxx@gmail.com>
;; Copyright (C) 2010, Andreas Marschke
;; Version: 0.1
;; Keywords: mocp, music
;; Compatibility: GNU Emacs 23.1.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;; Dependencies:
;; To use the full featureset of mocp.el you need the following things
;;    * either one of these IRC clients:
;;        - rcirc - an irc client for emacs
;;        - erc - the Emacs iRC client
;;      Both are shipped with GNU Emacs 23.1(previous versions not tested)
;;    * `dired.el' distributed with GNU Emacs

;;; Commentary:

;; This is a set of lisp commands that interface with the
;; music on console player.

;; Todo:

;;; Code:

(require 'erc)
(require 'rcirc)

(defgroup mocp nil
  "A simple interface to mocp."
  :group 'mocp)

(defcustom mocp-volume-change-amount 5
  "Amount of % to change in volume when using `mocp-volume-up' or
`mocp-volume-down'. "
  :type 'integer
  :group 'mocp)

(defun mocp-now-listening ()
  (shell-command-to-string
   "mocp --format \" now listening to \\\"%song\\\" from the Album \\\"%album\\\" performed by: %artist\""))

(defun mocp-next ()
  "Play next song in mocp's playlist"
  (interactive)
  (shell-command "mocp --next")
  ;; a caching Race Condition would otherwise show the previous track
  (sleep-for 1 0)
  (message  (mocp-now-listening))
  )

(defun mocp-previous ()
  "Play previous song in mocp's playlist"
  (interactive)
  (shell-command "mocp --previous ")
  ;; a caching Race Condition would otherwise show the previous track
  (sleep-for 1 0)
  (message  (mocp-now-listening))
  )

(defun mocp-stop ()
  "Stop playing."
  (interactive)
  (shell-command "mocp --stop ")
  (message "MOCP Playback STOPPED")
  )

(defun mocp-play ()
  "Start playing"
  (interactive)
  (shell-command "mocp --play ")
  ;; a caching Race Condition would otherwise show the previous track
  (sleep-for 1 0)
  (message  (mocp-now-listening))
  )

(defun mocp-toggle-pp ()
  "Toggle playing/pausing"
  (interactive)
  (shell-command "mocp --toggle-pause ")
  )
(defun mocp-shuffle-on ()
  "Turn on shuffle."
  (interactive)
  (shell-command "mocp --on shuffle")
  )
(defun mocp-repeat-on ()
  "Turn on repeat."
  (interactive)
  (shell-command "mocp --on repeat")
  )

(defun mocp-autonext-on ()
  "Turn on autonext."
  (interactive)
  (shell-command "mocp --on autonext")
  )
(defun mocp-shuffle-off ()
  "Turn off shuffle."
  (interactive)
  (shell-command "mocp --off shuffle")
  )
(defun mocp-repeat-off ()
  "Turn off repeat."
  (interactive)
  (shell-command "mocp --off repeat")
  )
(defun mocp-autonext-off ()
  "Turn off autonext."
  (interactive)
  (shell-command "mocp --off autonext")
  )
(defun mocp-volume-up ()
  "increase volume by 5"
  (interactive)
  (shell-command (format "mocp -v +%s" 5))
  )
(defun mocp-volume-down ()
  (interactive)
  (shell-command (format "mocp -v -%s" 5))
  )

(defun mocp-append-file-to-playlist ()
  "append a file or directory to your mocp playlist."
  (interactive)
  (shell-command (format "mocp -a '%s'" (dired-get-file-for-visit))))

(defun mocp-now-playing-irc-me ()
  "Post your currently playing song from mocp to the irc-channel"
  (interactive)

  (if (eq major-mode 'rcirc-mode )
      (rcirc-cmd-me (mocp-now-listening)))

  (if (eq major-mode 'erc-mode )
      (erc-cmd-ME (mocp-now-listening)))
  )

(provide 'mocp)
