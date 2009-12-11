;;; upside-down.el --- make regions of text upside-down

;; Copyright (C) 2008 Noah S. Friedman

;; Author: Noah Friedman <friedman@splode.com>
;; Maintainer: friedman@splode.com
;; Keywords: extensions
;; Created: 2008-10-14

;; $Id: upside-down.el,v 1.2 2009/05/13 04:35:08 friedman Exp $

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, you can either send email to this
;; program's maintainer or write to: The Free Software Foundation,
;; Inc.; 51 Franklin Street, Fifth Floor; Boston, MA 02110-1301, USA.

;;; Commentary:

;; ¿ʇı̣ əsnqɐ ʇ,uɐɔ noʎ ɟı̣ əpoɔı̣un sı̣ pooɓ ʇɐɥʍ

;; This toy lets you render a region of ascii text upside-down.  That is,
;; the characters in the region will be substituted with upside-down
;; equivalents (or the nearest approximation) from the unicode character set.
;; Running this function twice over a region should reverse the effect.

;; This might only work properly in utf8 buffers; I haven't tested other
;; coding systems.

;;; Code:

(defvar upside-down-char-map
  '((#x0021 . #x00A1)          ; !	¡ - INVERTED EXCLAMATION MARK
    (#x003F . #x00BF)          ; ?	¿ - INVERTED QUESTION MARK
    (#x0022 . #x201E)          ; "	„ - DOUBLE LOW-9 QUOTATION MARK
    (#x0027 . #x002C)          ; '	, - COMMA
    (#x002E . #x02D9)          ; .	˙ - DOT ABOVE

    (#x003B . #x061B)          ; ;	؛ - ARABIC SEMICOLON
    (#X002C . #x02BB)          ; ,	ʻ - MODIFIER LETTER TURNED COMMA
    (#x0026 . #x214B)          ; &	⅋ - TURNED AMPERSAND
    (#x005F . #x203E)          ; _	‾ - OVERLINE

    (#x0028 . #x0029)          ; (	)
    (#x003C . #x003E)          ; <	>
    (#x005B . #x005D)          ; [	]
    (#x007B . #x007D)          ; {	}

    ;;;;;;;;;;
    (#x0033 . #x0190)          ; 3	Ɛ - LATIN CAPITAL LETTER OPEN E
    (#x0034 . #x152D)          ; 4	ᔭ - CANADIAN SYLLABICS YA
    (#x0036 . #x0039)          ; 6	9 - DIGIT NINE
    (#x0037 . #x023D)          ; 7	Ƚ - LATIN CAPITAL LETTER L WITH BAR

    ;;;;;;;;;;

    (#x0041 . #x2200)          ; A	∀ - FOR ALL
    (#x0042 . #x10412)         ; B	𐐒 - DESERET CAPITAL LETTER BEE
    (#x0043 . #x0186)          ; C	Ɔ - LATIN CAPITAL LETTER OPEN O
    (#x0044 . #x15E1)          ; D	ᗡ - CANADIAN SYLLABICS CARRIER THA
    (#x0045 . #x018E)          ; E	Ǝ - LATIN CAPITAL LETTER REVERSED E
    (#x0046 . #x2132)          ; F	Ⅎ - TURNED CAPITAL F
    (#x0047 . #x2141)          ; G	⅁ - TURNED SANS-SERIF CAPITAL G
    (#x004A . #x017F)          ; J	ſ - LATIN SMALL LETTER LONG S
    (#x004B . #x22CA)          ; K	⋊ - RIGHT NORMAL FACTOR SEMIDIRECT PRODUCT
    (#x004C . #x2142)          ; L	⅂ - TURNED SANS-SERIF CAPITAL L
    (#x004D . #x0057)          ; M	W - LATIN CAPITAL LETTER W
    (#x0050 . #x0500)          ; P	Ԁ - CYRILLIC CAPITAL LETTER KOMI DE
    (#x0051 . #x038C)          ; Q	Ό - GREEK CAPITAL LETTER OMICRON WITH TONOS
    (#x0052 . #x1D1A)          ; R	ᴚ - LATIN LETTER SMALL CAPITAL TURNED R
    (#x0054 . #x22A5)          ; T	⊥ - UP TACK
    (#x0055 . #x2229)          ; U	∩ - INTERSECTION
    (#x0056 . #x0245)          ; V	Ʌ - LATIN CAPITAL LETTER TURNED V
    (#x0059 . #x2144)          ; Y	⅄ - TURNED SANS-SERIF CAPITAL Y

    ;;;;;;;;;;

    (#x0061 . #x0250)          ; a	ɐ - LATIN SMALL LETTER TURNED A
    (#x0062 . #x0071)          ; b	q - LATIN SMALL LETTER Q
    (#x0063 . #x0254)          ; c	ɔ - LATIN SMALL LETTER OPEN O
    (#x0064 . #x0070)          ; d	p - LATIN SMALL LETTER P
    (#x0065 . #x0259)          ; e	ə - LATIN SMALL LETTER TURNED E
    (#x0066 . #x025F)          ; f	ɟ - LATIN SMALL LETTER DOTLESS J WITH STROKE

    ;; More systems have fonts with U+0253 glyph than U+1D77
    (#x0067 . #x0253)          ; g	ɓ - LATIN SMALL LETTER B WITH HOOK
    (#x0067 . #x1D77)          ; g	ᵷ - LATIN SMALL LETTER TURNED G

    (#x0068 . #x0265)          ; h	ɥ - LATIN SMALL LETTER TURNED H

    ;; This code doesn't handle combining chars yet
    (#x0069 . #x1D09)          ; i	ᴉ - LATIN SMALL LETTER TURNED I
    (#x0069 . [#x0131 #x0323]) ; i	ı̣ - LATIN SMALL LETTER DOTLESS I + COMBINING DOT BELOW

    (#x006A . #x027E)          ; j	ɾ - LATIN SMALL LETTER R WITH FISHHOOK
    (#x006B . #x029E)          ; k	ʞ - LATIN SMALL LETTER TURNED K
    (#x006D . #x026F)          ; m	ɯ - LATIN SMALL LETTER TURNED M
    (#x006E . #x0075)          ; n	u - LATIN SMALL LETTER U
    (#x0072 . #x0279)          ; r	ɹ - LATIN SMALL LETTER TURNED R
    (#x0074 . #x0287)          ; t	ʇ - LATIN SMALL LETTER TURNED T
    (#x0076 . #x028C)          ; v	ʌ - LATIN SMALL LETTER TURNED V
    (#x0077 . #x028D)          ; w	ʍ - LATIN SMALL LETTER TURNED W
    (#x0079 . #x028E)          ; y	ʎ - LATIN SMALL LETTER TURNED Y
    ))

;; Like rassq, but also search sublists to see if the car is key
(defun upside-down-rassq (key list)
  (cond ((rassq key list))
        (t
         nil)))

;;;###autoload
(defun upside-down-region (beg end)
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))

      (while (not (eobp))
        (let* ((old (encode-char (char-after (point)) 'ucs))
               (new (or (cdr (assq old upside-down-char-map))
                        (car (rassq old upside-down-char-map))
                        old)))
          (delete-char 1)
          (insert (decode-char 'ucs new))))

      (goto-char (point-min))
      (insert (upside-down-nreverse-sequence
               (buffer-substring (point-min) (point-max))))
      (delete-region (point) (point-max)))))

(defun upside-down-nreverse-sequence (seq)
  "Like `nreverse', but operate on additional sequence types.
This should work for lists, vectors, bool-vectors, strings, and other
vector-like data structures."
  (cond ((listp seq)
         (nreverse seq))
        (t
         (let ((i 0)
               (l (1- (length seq))))
           (while (< i l)
             (aset seq i (prog1
                             (aref seq l)
                           (aset seq l (aref seq i))))
             (setq i (1+ i)
                   l (1- l))))
         seq)))

;; upside-down.el ends here
