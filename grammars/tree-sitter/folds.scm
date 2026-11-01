; Code folding for Magma (Pulsar modern Tree-sitter).
;
; A simple `@fold` runs from the end of the node's first row to the position
; named by `fold.endAt`. Blocks end with `end <keyword>`, so most folds stop
; just before the `end` and leave it visible.

; Definitions and loops: fold up to `end`.
(
  [
    (intrinsic_definition)
    (function_definition)
    (procedure_definition)
    (for_statement)
    (while_statement)
    (case_statement)
    (try_catch_statement)
  ] @fold
  (#set! fold.endAt lastChild.previousSibling.startPosition)
  (#set! fold.adjustToEndOfPreviousRow true))

; repeat ... until cond;  — stop before `until`.
((repeat_statement) @fold
  (#set! fold.endAt lastChild.previousSibling.startPosition)
  (#set! fold.adjustToEndOfPreviousRow true))

; if/elif/else: the `if` folds up to its first `elif`/`else` (or to `end`),
; and each branch folds on its own.
; (`capture.final` stops the plain `if` fold below from claiming the same node.)
((if_statement
  [(elif_clause) (else_clause)]) @fold
  (#set! fold.endAt firstNamedChild.nextNamedSibling.nextNamedSibling.startPosition)
  (#set! fold.adjustToEndOfPreviousRow true)
  (#set! capture.final))
((if_statement) @fold
  (#set! fold.endAt lastChild.previousSibling.startPosition)
  (#set! fold.adjustToEndOfPreviousRow true))
([(elif_clause) (else_clause) (when_clause)] @fold
  (#set! fold.endAt endPosition))

; Brackets and constructors: fold up to the closing delimiter.
[
  (argument_list)
  (parameters)
  (parenthesized_expression)
  (seqenum)
  (set)
  (indexed_set)
  (multiset)
  (formal_set)
  (literal_sequence)
  (tuple)
  (constructor)
  (recformat_constructor)
  (case_constructor)
] @fold

; /* block comments */ keep the closing `*/` visible.
((comment) @fold
  (#match? @fold "^/\\*")
  (#set! fold.endAt endPosition)
  (#set! fold.offsetEnd -2))

; {Multi-line intrinsic documentation} keeps the closing `}` visible.
((doc_string) @fold
  (#set! fold.endAt endPosition)
  (#set! fold.offsetEnd -1))
