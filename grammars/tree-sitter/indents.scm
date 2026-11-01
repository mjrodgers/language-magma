; Indentation hints for Magma (Pulsar modern Tree-sitter).
;
; `@indent` on row N means "indent row N + 1". `@dedent` means "dedent this
; row" when it is the first text on the row, and also cancels an earlier
; `@indent` on the same row. `@match` sets the row's level to that of the row
; where a reference node starts, which lets `end` line up with its opening
; keyword no matter how deeply the body was nested.
;
; While a block is still being typed, the tree is usually in an error state:
; `end`, `else` and friends may then be parsed as plain identifiers. The
; identifier rules near the bottom handle that case.


; IGNORE
; ======

; The keyword repeated after `end` (`end if`, `end function`, ...) must not
; open a new indent.
("end" . _ @_IGNORE_ (#set! capture.final))

; `error if cond, "msg";` is a statement, not a block.
(error_statement "if" @_IGNORE_ (#set! capture.final))

; `select ... else ...` is an expression.
(ternary_operator "else" @_IGNORE_ (#set! capture.final))

; `case< x | ... >` is an expression.
(case_constructor "case" @_IGNORE_ (#set! capture.final))



; OPENING A BLOCK
; ===============

[
  "then"          ; if ... then / elif ... then
  "do"            ; for ... do / while ... do
  "repeat"
  "try"
  "catch"         ; catch e
  "else"          ; if / case
  "function"      ; f := function(x)  /  function f(x)
  "procedure"     ; p := procedure(x) /  procedure p(x)
  "case"          ; case x:
  "when"          ; when 1:
] @indent

; Some code bases indent the docstring itself; that style is a package
; setting.
("intrinsic" @indent
  (#is? test.config "language-magma.indentation.indentDocstring"))

; An intrinsic's body starts after its documentation string, which usually
; sits flush with the `intrinsic` line:
;
;   intrinsic Foo(x::RngIntElt) -> RngIntElt
;   {Returns x.}
;       return x;
;   end intrinsic;
;
; In a complete tree the body lines up one level in from the `intrinsic` row,
; however the docstring's continuation lines were indented.
(intrinsic_definition
  (doc_string) @match.next
  (#is? indent.matchesComparisonRow endPosition)
  (#set! indent.match parent.startPosition)
  (#set! indent.offset 1))
; While the intrinsic is still being typed there is no complete
; `intrinsic_definition` yet, so fall back to one level in from the row where
; the docstring starts.
((doc_string) @match.next
  (#is? indent.matchesComparisonRow endPosition)
  (#set! indent.match startPosition)
  (#set! indent.offset 1))

; Multi-line brackets.
["(" "[" "{" "{@" "{*" "{!" "[*" "\\(" "\\["] @indent
[")" "]" "}" "@}" "*}" "!}" "*]"] @dedent

; Constructors spanning several rows: sub< G |
;                                         ... >
(constructor "<" @indent)
(constructor ">" @dedent)
(recformat_constructor "<" @indent)
(recformat_constructor ">" @dedent)
(case_constructor "<" @indent)
(case_constructor ">" @dedent)


; AFTER A MULTI-ROW STATEMENT
; ===========================

; When a statement that started on an earlier row ends on the previous row,
; the next row goes back to the statement's own level. This undoes hanging
; indents such as
;
;   result := [ x : x in L |
;       IsSquare(x) ];
;   next := 1;
([(block (_) @match.next) (program (_) @match.next)]
  (#is? indent.matchesComparisonRow endPosition)
  (#is-not? indent.matchesComparisonRow startPosition)
  (#set! indent.match startPosition))


; CLOSING A BLOCK
; ===============

; In a complete tree, line each closing keyword up with the row its block
; starts on. For `f := function(x)` that is the row of the assignment. The
; parent types are spelled out because, while a block is still being typed,
; these keywords can end up inside an ERROR node that starts somewhere else.
([
  (intrinsic_definition "end" @match)
  (function_definition "end" @match)
  (procedure_definition "end" @match)
  (if_statement "end" @match)
  (for_statement "end" @match)
  (while_statement "end" @match)
  (try_catch_statement "end" @match)
  (repeat_statement "until" @match)
  (try_catch_statement "catch" @match)
 ]
  (#set! indent.match parent.startPosition))

(if_statement
  (elif_clause "elif" @match
    (#set! indent.match parent.parent.startPosition)))
(if_statement
  (else_clause "else" @match
    (#set! indent.match parent.parent.startPosition)))

; Inside `case`, each `when` and the `else` sit one level in:
;
;   case x:
;       when 1:
;           print "one";
;       else
;           print "other";
;   end case;
(case_statement
  (when_clause "when" @match
    (#set! indent.match parent.parent.startPosition)
    (#set! indent.offset 1)))
(case_statement "else" @match
  (#set! indent.match parent.startPosition)
  (#set! indent.offset 1))

; `end case` closes two levels at once, which an ordinary dedent can't do.
; `indent.force` lets this fire once the whole `end case;` has been typed
; and the statement parses; `test.firstTextOnRow` keeps it to rows that start
; with `end`.
(case_statement "end" @match
  (#is? test.firstTextOnRow)
  (#set! indent.match parent.startPosition)
  (#set! indent.force true))


; FALLBACKS FOR INCOMPLETE TREES
; ==============================

["end" "until" "catch" "elif" "else"] @dedent

; A second `when` follows the previous `when`'s body.
(ERROR (when_clause) . "when" @dedent)

; While typing, a lone `end`, `else`, ... is often parsed as an identifier.
((identifier) @dedent
  (#match? @dedent "^(end|else|elif|until|catch)$"))

; A trailing `<` or `|` almost always opens a multi-row constructor, even
; before the tree knows it is one:  G := sub< Sym(4) |
(["<" "|"] @indent
  (#is? test.lastTextOnRow))
(">" @dedent)
