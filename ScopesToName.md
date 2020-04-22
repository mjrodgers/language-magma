# Scopes currently used in language-magma
* name: "comment.block.magma"
    * captures name: "punctuation.definition.comment.magma"
* name: "invalid.illegal.stray-comment-end.magma"
* name: "comment.line.double-slash.magma"
    * beginCaptures: name: "punctuation.definition.comment.magma"
    * name: "punctuation.separator.continuation.magma"
* name: "invalid.illegal.end-statement.magma"
* name: "constant.language.magma"
* name: "constant.numeric.magma"
* name: "string.quoted.double.magma"
    * beginCaptures: name: "punctuation.definition.string.begin.magma"
    * endCaptures: name: "punctuation.definition.string.end.magma"
    * subpatterns
        * include: "#string_escaped_char"
        * include: "#string_placeholder"
* name: "string.quoted.single.magma"
    * beginCaptures: name: "punctuation.definition.string.begin.magma"
    * endCaptures: name: "punctuation.definition.string.end.magma"
    * subpatterns
        * include: "#string_escaped_char"
* name: "variable.reference.magma"
* name: "variable.attribute.magma"
* name: "meta.record.magma"
    * captures
        * name: "keyword.function.statement.magma"
        * name: "keyword.operator.magma"
        * name: "variable.magma"



# Scopes used by MagicPython
* name: "invalid.deprecated.semicolon.python"
* name: "comment.line.number-sign.python"
    * contentName: "meta.typehint.comment.python"
    * beginCaptures
        * name: "meta.typehint.comment.python"
        * name: "comment.typehint.directive.notation.python"
    * subpatterns
        * name: "comment.typehint.ignore.notation.python"
        * name: "comment.typehint.type.notation.python"
        * name: "comment.typehint.punctuation.notation.python"
        * name: "comment.typehint.variable.notation.python"
