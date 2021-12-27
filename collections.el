;;; INIT-COLLECTION --- This file is for collections,
;; a package that can collect text style
;; information to your self-defined places.
;;
;; It is a light-weight emacs package that encourage you collect
;; any fragmented important information in emacs (e.g. codes,
;; paragraphs, outputs in terminal and any others)
;; into a single file. It is light-weight, quick and no-interruptted.
;;
;; Author: Zi Liang <liangzid@stu.xjtu.edu.cn>
;; Copyright © 2021, ZiLiang, all rights reserved.
;; Created: 22 December 2021
;;
;;; Commentary:
;; =================================begin commentary=====================================
;; 1. load this package
;`(load-file "./collections.el")'
;`(require 'easy-collections)'
;; 2. custom setting variables if you needed.
;; 2.1 setting your save path. default:"~/.emacs.d/collected/box.org"
; `(setq collected-save-path "your/file/path/for/collections/")'
;; 2.2 setting your save format. default:
;;--------------------------------------------------------------------------
;; ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> COLLECTED TIME: </time>
;; >> FROM BUFFER: </buffer>
;; >> FROM PATH: </filepath>
;; #+BEGIN_SRC </mode> 
;; </region> 
;; #+END_SRC 
;; >>YOUR COMMENT: </comment>
;; "
;;--------------------------------------------------------------------------
; `(setq collected-format "YOUR/FORMAT/")'
;; 3. setting your keybindings to quick running collected command.
; `(global-set-key (kbd "YOUR-KEY-BINGDING") 'collected-run)'
;; 4. you can also running with "M-x collected-run"
;; =================================end commentary=====================================
;;; Code:

(defun create-empty-file-if-no-exists(filePath)
   "Create a file with FILEPATH parameter."
   (if (file-exists-p filePath)
       (message (concat  "File " (concat filePath " already exists")))
     (with-temp-buffer (write-file filePath))))


(defvar collected-save-path
  "~/.emacs.d/collected/box.org"
  "The path of file that you want store your collections, I recommend you apply a org file.")

(defvar collected-format (concat
			  ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
			  ">> COLLECTED TIME: </time>\n\n"
			  ">> FROM BUFFER: </buffer>\n\n"
			  ">> FROM PATH: </filepath>\n\n"
			  "#+BEGIN_SRC </mode> \n"
			  "</region> \n"
			  "#+END_SRC \n\n"
			  ">>YOUR COMMENT: </comment>\n\n")

  "This value means the default format you want to insert. 
   The default is a pre-setting org format. 
   Some special information can be insert, such as:
   </time>, which is the collected time;
   </buffer> which is the buffer name;
   </filepath> which is the file path for selected buffer if it exists;
   </region> which is the content you want to save;
   </comment> which is the comment if you want to insert a comment.")


(defun get-buffer-mode (buffer-or-string)
  (with-current-buffer buffer-or-string
    major-mode))

(defun progmode-p (major-mode-name)
  " is current major mode is a prog mode? if true, return t, else return nil"
  (let ((src-code-types
	 '("emacs-lisp" "python" "C" "sh" "java" "js" "clojure" "C++" "css"
            "calc" "asymptote" "dot" "gnuplot" "ledger" "lilypond" "mscgen"
            "octave" "oz" "plantuml" "R" "sass" "screen" "sql" "awk" "ditaa"
            "haskell" "latex" "lisp" "matlab" "ocaml" "org" "perl" "ruby"
            "scheme" "sqlite"))
	)
    )
  nil)
;; mode2prog




(defun collected-run ()
 "When you select a region and execute this function, 
  it will copy the contents you have seleted,
  and then paste them into a text file ``collected-save-path'' you have pre-defined. 
  And some information like collected-time, collected-buffer-from,
  collected-file-path-from, as well as comments you have 
  written will be recorded with your self-defined format ``collected-format''."
  (interactive)
  (let* ((text-return collected-format))
    (progn
      (if (use-region-p)
	  (progn
	    ;; running insert time command if have </time>
	    (if (string-match-p (regexp-quote "</time>") collected-format)
		;; replace
		(setq text-return
		      (s-replace "</time>" (format-time-string "%F, %A, %T") text-return))
	      )

	    ;; running insert buffer if have </buffer>
	    (if (string-match-p (regexp-quote "</buffer>") collected-format)
		;; replace
		(setq text-return
		      (s-replace "</buffer>" (buffer-name) text-return))
	      )

	    ;; running insert filepath if have </filepath>
	    (if (string-match-p (regexp-quote "</filepath>") collected-format)
		;; replace
		(if (buffer-file-name)
		    (setq text-return
			  (s-replace "</filepath>" (concat "[[file:"
							   (buffer-file-name)
							   "]["
							   (buffer-file-name)
							   "]]")
				     text-return))
		  (setq text-return
			(s-replace "</filepath>" "NONE" text-return))
		  )
	      )

	    ;; running insert prog-mode if its main mode is prog-mode
	    (if (string-match-p (regexp-quote "</mode>") collected-format)
		(progn
		  ;; get current buffer mode
		  (setq current-major-mode (get-buffer-mode (current-buffer)))
		  (if (progmode-p current-major-mode)
		      (setq text-return
			    (s-replace "</mode>" (mode2prog current-buffer-mode) text-return))
		    (setq text-return
			  (s-replace "</mode>" "" text-return))
		      )
		  )
	      )

	    ;; running insert region contents 
	      (setq text-return
		    (s-replace "</region>" (buffer-substring-no-properties
				    (region-beginning) (region-end))
			       text-return))

	    ;; running insertcomment
	    (if (string-match-p (regexp-quote "</comment>") collected-format)
		;; replace
		(setq text-return
		      (s-replace "</comment>" (read-from-minibuffer "your comment: ") text-return))
	      )

	    ;; save and exit files
	    (create-empty-file-if-no-exists collected-save-path)
	    (append-to-file text-return nil (expand-file-name collected-save-path))

	    (message (concat "DONE. Save to: " (expand-file-name collected-save-path)))

	    )
	(message "no regions need to be collected."))

    )))

(defun collect-default-open ()
  "open default save file."
  (find-file collected-save-path)
  (message "default file open done. 0.0"))



(provide 'easy-collections)
;;; init-collection.el ends here
