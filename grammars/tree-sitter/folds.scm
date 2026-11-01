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

; Runs of `//` line comments fold together, from the end of the first
; comment's row to the end of the last comment:
;
;   // NOTE should this be a map?          ← fold starts here
;   // NOTE we aren't using xLinesW here
;   // debatable whether we need xLinesI   ← and ends here
;
; Each comment is its own node, so this takes three patterns: a divided fold
; that starts at the first comment of a run and ends at the last. The
; `@fold.end` patterns come first so that the `capture.final` below doesn't
; swallow them.

; The last comment of a run: the next node isn't a line comment…
((comment) @fold.end
  .
  _ @_IGNORE_.next
  (#match? @fold.end "^//")
  (#not-match? @_IGNORE_.next "^//")
  (#set! fold.endAt endPosition))

; …or there is no next node. (An anchor can't express this, because
; Tree-sitter skips comments when matching anchors.)
((comment) @fold.end
  (#match? @fold.end "^//")
  (#is? test.last)
  (#set! fold.endAt endPosition))

; A line comment right after another comment can't start a run. (The first
; comment is left uncaptured: `capture.final` applies to every capture in the
; pattern, and the first comment may itself start a run.)
((comment)
  .
  (comment) @_IGNORE_
  (#match? @_IGNORE_ "^//")
  (#set! capture.final))

; The first comment of a run of at least two, on a row of its own.
((comment) @fold.start
  .
  (comment) @_IGNORE_.following
  (#match? @fold.start "^//")
  (#match? @_IGNORE_.following "^//")
  (#is? test.firstTextOnRow))
