(in-package :mona-lisa-gol)

(defconstant LIVE t)
(defconstant DEAD nil)

(defstruct life grid rows cols)

(defun life-from-lists (init)
  (let ((rows (list-length init))
        (cols (list-length (car init))))
    (make-life :grid (make-array (list rows cols) :initial-contents init)
               :rows rows
               :cols cols)))

(defun life-get-cell (life row col)
  (aref (life-grid life)
        (mod row (life-rows life))
        (mod col (life-cols life))))

(alexandria:define-constant +neighbour-offsets+
  (list (list (- 1) (- 1))
        (list (- 1) 0)
        (list (- 1) 1)
        (list 0 (- 1))
        (list 0 1)
        (list 1 (- 1))
        (list 1 0)
        (list 1 1)))

(defun life-next-state (life)
  (let ((next-grid
          (make-array (list (life-rows life) (life-cols life))
                      :element-type 'boolean
                      :initial-element DEAD)))
    (loop for i from 0 to (1- (life-rows life)) do
          (loop for j from 0 to (1- (life-cols life)) do
                (let ((current (life-get-cell life i j))
                      (neighbours (list-length (life-live-neighbours life i j))))
                  (if (or (and (equalp current LIVE)
                               (find neighbours '(2 3)))
                          (and (equalp current DEAD)
                               (= neighbours 3)))
                      (setf (aref next-grid i j) LIVE)
                      nil))))
    (destructuring-bind (rows cols) (array-dimensions next-grid)
      (make-life :grid next-grid
                 :rows rows
                 :cols cols))))

;; Buggy for small grids, counts self as a neighbour.
(defun life-live-neighbours (life row col)
  (let ((coords (list row col)))
    (remove DEAD
            (mapcar
             (lambda (coords)
               (destructuring-bind (row col) coords
                 (life-get-cell life row col)))
             (loop for offsets in +neighbour-offsets+ collect
                   (mapcar #'+ offsets coords))))))

(defun compare-lives (l1 l2)
  (let* ((diff
           (mapcar #'equalp
                   (2d-array-to-flat-list (life-grid l1))
                   (2d-array-to-flat-list (life-grid l2))))
         (diff-size (list-length diff))
         (matching (list-length (remove nil diff)))
         (non-matching (- diff-size matching)))
    (values matching non-matching)))

(defun 2d-array-to-flat-list (array)
  (flatten
   (loop for i below (array-dimension array 0) collect
         (loop for j below (array-dimension array 1) collect
               (aref array i j)))))

(defun flatten (xs)
  (cond ((null xs) nil)
        (t (append (car xs) (flatten (cdr xs))))))

(defun random-life (rows cols)
  (life-from-lists
   (loop for _ from 1 upto rows collect
         (loop for _ from 1 upto cols collect
               (if (zerop (random 2))
                   DEAD
                   LIVE)))))

(defun load-png-as-life (path)
  (life-from-lists
   (let* ((pixels (png-read:image-data (png-read:read-png-file path)))
          (rows (array-dimension pixels 0))
          (cols (array-dimension pixels 1)))
     (loop for row from 0 upto (1- rows) collect
           (loop for col from 0 upto (1- cols) collect
                 (let ((max-rgb
                         (apply #'max (mapcar #'(lambda (channel)
                                                  (aref pixels row col channel))
                                              (list 0 1 2)))))
                   (if (< max-rgb 255)
                       LIVE ; black pixels are live cells
                       DEAD)))))))
