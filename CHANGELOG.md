# Changelog

## 3.0.0

- Added a modern Tree-sitter grammar (`tree-sitter-magma` compiled to WASM) with highlighting, folding, indentation, symbols and locals queries.
- Runs of `//` line comments fold together, as they did with the TextMate grammar.
- Added the **Indent intrinsic docstrings** setting.
- Renamed the scope from `source.Magma` to `source.magma`, so the grammar, settings and snippets share one scope (in 2.x the snippets used `source.magma` while the main grammar used `source.Magma`, so they only fired with the alternative grammars).
- `.m` files are claimed only when their content looks like Magma, so Objective-C and MATLAB files are left alone.
- Added `.mag` to the file types.
- Removed the duplicate `magma2`/`magma3` grammars and the `MagmaTS` stub.
- Moved the intrinsic completion list to pulsar-ide-magma.
- Snippets: fixed `error if` syntax, swapped `vp`/`vt` (they inserted each other's statement), `import` now inserts the `: names` part. Added `try`, `elif`, `vprintf`, `declare verbose`, `declare attributes`, `Attach` and `AttachSpec`.
- Replaced the generated placeholder specs with grammar specs.

## 2.1.1

- TextMate grammar translated from David Howden's TextMate bundle.
