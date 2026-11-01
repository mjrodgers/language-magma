; Syntax highlighting for Magma (Pulsar modern Tree-sitter).
;
; Scope names follow the TextMate conventions used by Pulsar's built-in
; grammars, so any syntax theme colours them sensibly. Rules higher in the
; file win when they use `capture.final`.

; COMMENTS
; ========

((comment) @comment.block.magma
  (#match? @comment.block.magma "^/\\*"))

((comment) @punctuation.definition.comment.begin.magma
  (#match? @punctuation.definition.comment.begin.magma "^/\\*")
  (#set! adjust.startAndEndAroundFirstMatchOf "^/\\*"))

((comment) @punctuation.definition.comment.end.magma
  (#match? @punctuation.definition.comment.end.magma "\\*/$")
  (#set! adjust.startAndEndAroundFirstMatchOf "\\*/$"))

((comment) @comment.line.double-slash.magma
  (#match? @comment.line.double-slash.magma "^//"))

((comment) @punctuation.definition.comment.magma
  (#match? @punctuation.definition.comment.magma "^//")
  (#set! adjust.startAndEndAroundFirstMatchOf "^//"))


; STRINGS
; =======

; An intrinsic's documentation string: `{Returns the order of G.}`
(doc_string) @comment.block.documentation.magma

(string) @string.quoted.double.magma

((string) @punctuation.definition.string.begin.magma
  (#set! adjust.startAndEndAroundFirstMatchOf "^\""))

((string) @punctuation.definition.string.end.magma
  (#set! adjust.startAndEndAroundFirstMatchOf "\"$"))

; The file name in `load "foo.m";`, `import "foo.m": f;` and the like.
(load_directive (string) @string.quoted.double.other.path.magma)
(import_directive filename: (string) @string.quoted.double.other.path.magma)


; CONSTANTS
; =========

(true) @constant.language.boolean.true.magma
(false) @constant.language.boolean.false.magma

((integer) @constant.numeric.integer.hexadecimal.magma
  (#match? @constant.numeric.integer.hexadecimal.magma "^0[xX]")
  (#set! capture.final))
(integer) @constant.numeric.integer.magma
(real) @constant.numeric.float.magma

; `$1`, `$$`: references to previous results in an interactive session.
(dollar) @variable.language.previous-result.magma
(double_dollar) @variable.language.previous-result.magma

; The `_` placeholder in multiple assignments and comprehensions.
(anonymous_identifier) @variable.language.anonymous.magma

; `print x: Magma;` and friends.
(print_level_statement
  ["Default" "Hex" "Latex" "Magma" "Maximal" "Minimal"] @constant.language.print-level.magma)


; DEFINITIONS
; ===========

; intrinsic Name(...) -> ...
(intrinsic_definition
  name: (identifier) @entity.name.function.intrinsic.magma)

; function Name(...)  /  procedure Name(...)
(function_definition
  name: (identifier) @entity.name.function.magma)
(procedure_definition
  name: (identifier) @entity.name.function.procedure.magma)

; Name := function(...)  /  Name := procedure(...)
(assignment
  left: (identifier) @entity.name.function.magma
  right: (function_definition))
(assignment
  left: (identifier) @entity.name.function.procedure.magma
  right: (procedure_definition))

; Name := func< x | ... >  /  proc< ... >
(assignment
  left: (identifier) @entity.name.function.magma
  right: (constructor
    name: (identifier) @_IGNORE_
    (#match? @_IGNORE_ "^(func|proc)$")))

; forward Name;
(forward (identifier) @entity.name.function.forward.magma)

; Parameters. (The parser's `parameters` field cannot be used in queries, so
; intrinsic parameters are found by position instead.)
(parameters (identifier) @variable.parameter.magma)
(parameters (ref_identifier (identifier) @variable.parameter.reference.magma))
(intrinsic_definition ["(" ","] . (identifier) @variable.parameter.magma)
(intrinsic_definition (typed_identifier . (identifier) @variable.parameter.magma))
(intrinsic_definition (ref_identifier (identifier) @variable.parameter.reference.magma))
(intrinsic_definition (ref_typed_identifier (identifier) @variable.parameter.reference.magma))

; Optional (named) parameters: `: Proof := true`
(optional_parameter
  name: (identifier) @variable.parameter.optional.magma)
(optional_argument
  (identifier) @variable.parameter.optional.magma
  (#is? test.first))

; `~x` passes a reference.
(ref_identifier "~" @keyword.operator.reference.magma)
(ref_typed_identifier "~" @keyword.operator.reference.magma)

; Record formats: recformat< n : RngIntElt, s >
(recformat_constructor
  "recformat" @storage.type.recformat.magma)
(field_definition
  name: (identifier) @variable.other.member.magma)
(recformat_constructor
  (identifier) @variable.other.member.magma)

; declare type MyType[MyElt];  declare attributes Grp: Foo;  declare verbose Flag, 2;
(declare_statement "declare" @storage.modifier.declare.magma)
(type_declaration "type" @storage.type.declare.magma)
(type_declaration
  (type . (identifier) @entity.name.type.magma)
  (#set! capture.final))
(attribute_declaration "attributes" @storage.type.declare.magma)
(attribute_declaration
  category: (identifier) @support.type.magma)
(attribute_declaration
  attribute: (identifier) @variable.other.member.magma)
(verbosity_declaration "verbose" @storage.type.declare.magma)
(verbosity_declaration
  function: (identifier) @constant.other.verbose-flag.magma)

; Verbose flags in vprint / vtime.
(vprint_statement
  flag: (identifier) @constant.other.verbose-flag.magma)
(vtime_statement
  (identifier) @constant.other.verbose-flag.magma
  (#is? test.first))


; TYPES
; =====

; x::RngIntElt, -> SeqEnum[RngIntElt]
(type (identifier) @support.type.magma)
(type "." @support.type.any.magma
  (#set! capture.final))
(typed_identifier "::" @punctuation.separator.type.magma)
(ref_typed_identifier "::" @punctuation.separator.type.magma)
(intrinsic_definition "->" @punctuation.separator.return-type.magma
  (#set! capture.final))


; FUNCTION CALLS
; ==============

(call
  function: (identifier) @support.other.function.magma)

; Built-in constructors: sub< G | ... >, quo<...>, hom<...>, ideal<...>, ...
((constructor
  name: (identifier) @support.function.constructor.magma)
  (#match? @support.function.constructor.magma "^(sub|quo|ext|ncl|lideal|rideal|ideal|hom|map|pmap|iso|rec|func|proc|elt|car|cop|Group|Monoid|Semigroup|PolycyclicGroup|SLPGroup|FPGroup|AbelianGroup|GrpFP)$")
  (#set! capture.final))

; Generator names on the left: R<x, y> := PolynomialRing(...);
(assignment
  left: (constructor
    name: (identifier) @variable.other.assignment.magma
    (identifier) @variable.other.generator.magma))

(constructor ["<" ">"] @punctuation.definition.constructor.magma)
(constructor_elements "|" @punctuation.separator.constructor.magma)
(constructor_options ":" @punctuation.separator.constructor.magma)
(tuple ["<" ">"] @punctuation.definition.tuple.magma)
(case_constructor ["<" ">"] @punctuation.definition.constructor.magma)
(recformat_constructor ["<" ">"] @punctuation.definition.constructor.magma)


; ATTRIBUTES
; ==========

; G`Order, G``"Order"
(attribute "`" @punctuation.accessor.attribute.magma)
(attribute "``" @punctuation.accessor.attribute.magma)
(attribute
  (identifier) @variable.other.attribute.magma
  (#is? test.last))
(backtick_identifier) @variable.other.attribute.magma


; KEYWORDS
; ========

; Block keywords. The repeated keyword after `end` (as in `end if`) gets the
; same scope as the opening keyword.
(intrinsic_definition ["intrinsic" "end"] @storage.type.function.intrinsic.magma
  (#set! capture.final))
(function_definition ["function" "end"] @storage.type.function.magma
  (#set! capture.final))
(procedure_definition ["procedure" "end"] @storage.type.function.procedure.magma
  (#set! capture.final))

(if_statement ["if" "then" "end"] @keyword.control.conditional.magma
  (#set! capture.final))
(elif_clause ["elif" "then"] @keyword.control.conditional.magma
  (#set! capture.final))
(else_clause "else" @keyword.control.conditional.magma
  (#set! capture.final))
(case_statement ["case" "end" "else"] @keyword.control.conditional.case.magma
  (#set! capture.final))
(when_clause "when" @keyword.control.conditional.case.magma
  (#set! capture.final))
(case_constructor "case" @keyword.control.conditional.case.magma
  (#set! capture.final))
(ternary_operator ["select" "else"] @keyword.control.conditional.ternary.magma
  (#set! capture.final))

(for_statement ["for" "do" "end"] @keyword.control.repeat.magma
  (#set! capture.final))
(for_quantifier ["to" "by"] @keyword.control.repeat.magma
  (#set! capture.final))
(while_statement ["while" "do" "end"] @keyword.control.repeat.magma
  (#set! capture.final))
(repeat_statement ["repeat" "until"] @keyword.control.repeat.magma
  (#set! capture.final))
(break_statement) @keyword.control.flow.break.magma
(continue_statement) @keyword.control.flow.continue.magma
(return_statement "return" @keyword.control.flow.return.magma
  (#set! capture.final))

(try_catch_statement ["try" "catch" "end"] @keyword.control.exception.magma
  (#set! capture.final))
(error_statement "error" @keyword.control.exception.magma
  (#set! capture.final))
(error_statement "if" @keyword.control.conditional.magma
  (#set! capture.final))
(require_statement ["require" "requirege" "requirerange"] @keyword.control.exception.require.magma
  (#set! capture.final))
(assert_statement ["assert" "assert2" "assert3"] @keyword.control.exception.assert.magma
  (#set! capture.final))

; Fallback for keywords in partially typed code (inside ERROR nodes).
[
  "if" "then" "elif" "else" "case" "when" "select"
] @keyword.control.conditional.magma
[
  "for" "while" "repeat" "until" "do" "to" "by"
] @keyword.control.repeat.magma
[
  "try" "catch"
] @keyword.control.exception.magma
[
  "function" "procedure" "intrinsic"
] @storage.type.function.magma
("end" @keyword.control.end.magma (#set! capture.shy))

; Statements and directives.
[
  "print" "printf" "fprintf" "vprint" "vprintf" "read" "readi"
] @keyword.other.print.magma
[
  "load" "iload" "import"
] @keyword.control.import.magma
[
  "save" "restore" "forward" "delete" "local" "quit" "exit"
  "time" "vtime" "eval"
] @keyword.other.magma
[(clear) (freeze)] @keyword.other.magma


; OPERATORS
; =========

; Word operators: and, or, not, in, eq, mod, cat, ...
[
  "and" "or" "xor" "not"
  "eq" "ne" "lt" "le" "gt" "ge" "cmpeq" "cmpne"
  "in" "notin" "subset" "notsubset" "adj" "notadj"
  "mod" "div" "cat" "join" "meet" "diff" "sdiff"
  "is" "assigned" "exists" "forall" "random" "where"
] @keyword.operator.word.magma

[
  ":=" "+:=" "-:=" "*:=" "/:=" "^:=" "and:=" "or:=" "xor:=" "cat:=" "join:="
  "meet:=" "diff:=" "sdiff:=" "mod:=" "div:="
] @keyword.operator.assignment.magma

(where_expression ["is" ":="] @keyword.operator.assignment.where.magma)

["+" "-" "*" "/" "^"] @keyword.operator.arithmetic.magma
["&+" "&*" "&-" "&and" "&or" "&cat" "&join" "&meet"] @keyword.operator.reduction.magma
["->" ":->"] @keyword.operator.mapping.magma
["@" "@@"] @keyword.operator.image.magma
"#" @keyword.operator.length.magma
".." @keyword.operator.range.magma
"..." @keyword.operator.range.magma
["!" "!!"] @keyword.operator.coercion.magma

; `=` in group relations: Group< a, b | a^2 = b^3 = 1 >
(group_relation "=" @keyword.operator.relation.magma)


; PUNCTUATION
; ===========

";" @punctuation.terminator.statement.magma
"," @punctuation.separator.comma.magma
(seqenum ":" @punctuation.separator.comprehension.magma)
(set ":" @punctuation.separator.comprehension.magma)
(seqenum "|" @punctuation.separator.comprehension.magma)
(set "|" @punctuation.separator.comprehension.magma)
"." @punctuation.accessor.magma

["(" ")"] @punctuation.definition.parenthesis.magma
["[" "]"] @punctuation.definition.sequence.magma
["[*" "*]"] @punctuation.definition.sequence.formal.magma
["{" "}"] @punctuation.definition.set.magma
["{@" "@}"] @punctuation.definition.set.indexed.magma
["{*" "*}"] @punctuation.definition.set.multi.magma
["{!" "!}"] @punctuation.definition.set.formal.magma


; VARIABLES
; =========

; Anything not claimed above.
((identifier) @variable.other.magma
  (#set! capture.shy))
