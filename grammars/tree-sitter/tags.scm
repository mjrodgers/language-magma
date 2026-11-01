; Symbols for Pulsar's symbols-view (Go to Symbol / Go to Declaration).

(intrinsic_definition
  name: (identifier) @name
  (#set! symbol.tag "intrinsic")
  (#set! symbol.icon "package")) @definition.function

(function_definition
  name: (identifier) @name) @definition.function

(procedure_definition
  name: (identifier) @name
  (#set! symbol.tag "procedure")) @definition.function

(assignment
  left: (identifier) @name
  right: (function_definition)) @definition.function

(assignment
  left: (identifier) @name
  right: (procedure_definition)
  (#set! symbol.tag "procedure")) @definition.function

; f := func< x | ... >;
(assignment
  left: (identifier) @name
  right: (constructor
    name: (identifier) @_kind
    (#match? @_kind "^(func|proc)$"))) @definition.function

; RF := recformat< ... >;
(assignment
  left: (identifier) @name
  right: (recformat_constructor)
  (#set! symbol.tag "struct")) @definition.struct

; declare type MyType[MyElt];
(type_declaration
  (type (identifier) @name)
  (#set! symbol.tag "type")) @definition.class

; declare verbose MyFlag, 3;
(verbosity_declaration
  function: (identifier) @name
  (#set! symbol.tag "verbose")) @definition.constant

; forward f;
(forward
  (identifier) @name
  (#set! symbol.tag "forward")) @definition.function

; declare attributes Grp: Order, Name;  (one symbol per attribute, with the
; category as context)
(attribute_declaration
  ":"
  (identifier) @definition.field @name
  (#set! symbol.tag "attribute")
  (#set! symbol.contextNode "parent.firstNamedChild"))

; RF := recformat< n : RngIntElt, s >;  (one symbol per field, with the
; format's name as context)
(recformat_constructor
  (field_definition
    name: (identifier) @definition.field @name
    (#set! symbol.tag "field")
    (#set! symbol.contextNode "parent.parent.parent.firstNamedChild")))
(recformat_constructor
  (identifier) @definition.field @name
  (#set! symbol.tag "field")
  (#set! symbol.contextNode "parent.parent.firstNamedChild"))
