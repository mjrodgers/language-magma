# language-magma

Support for the [Magma](https://magma.maths.usyd.edu.au/magma/) computer algebra language in [Pulsar](https://pulsar-edit.dev).

Version 3 adds a modern Tree-sitter grammar built on [edgarcosta/tree-sitter-magma](https://github.com/edgarcosta/tree-sitter-magma). It provides:

- **Highlighting** that understands Magma's structure: intrinsic, function and procedure definitions and their parameters, typed parameters (`G::GrpPerm`), optional parameters (`: Proof := true`), `~` references, constructors (`sub< G | ... >`, `hom< ... >`, `rec< ... >`), generator names (`R<x, y> := ...`), attributes (``G`Order``), docstrings, verbose flags and the word operators (`eq`, `in`, `cat`, `mod`, ...).
- **Indentation** for every block form, including `case`/`when`, `try`/`catch`, `repeat`/`until`, intrinsic docstrings and multi-line brackets and constructors. `end` lines up with the row its block starts on, so `f := function(x) ... end function;` works too.
- **Folding** of definitions, loops, each branch of an `if`, `case` arms, block comments, runs of two or more `//` comments, docstrings and multi-line brackets.
- **Symbols** for **Symbols View: Toggle File Symbols** (<kbd>Cmd/Ctrl-R</kbd>): intrinsics, functions, procedures (named or assigned), record formats, declared types and verbose flags.
- **Snippets** for the common statements and constructors.

The original TextMate grammar is still included. Pulsar uses it when **Core: Use Tree-sitter Parsers** is off.

For a Magma session in a terminal, sending code to it, completions and project-wide symbols, install the companion package `pulsar-ide-magma`.

## Requirements

Pulsar 1.127 or later.

## File types

`.m`, `.mag`, `.magma` and `.mgm`. Objective-C and MATLAB also use `.m`. A `.m` file that contains `:=` or a Magma block ending such as `end if;` is opened as Magma. To force it, put this in your `config.cson`:

```coffee
"*":
  core:
    customFileTypes:
      "source.magma": ["m"]
```

`.spec` files (package spec files for `AttachSpec`) get a small grammar of their own.

## Settings

**Indentation → Indent intrinsic docstrings**: indent the `{...}` docstring one level under the `intrinsic` line instead of leaving it flush with it.

Scope-specific editor settings can be set for `.source.magma`, for example:

```coffee
".source.magma":
  editor:
    tabLength: 4
```

## Upgrading from 2.x

- The grammar's scope name is now `source.magma` (it was `source.Magma`). If your `config.cson`, keymap or stylesheet mentions `source.Magma` or `data-grammar='source Magma'`, change it to the lower-case form.
- The alternative grammars `magma2`, `magma3` and the stub `MagmaTS` were removed.
- The 8,600-name intrinsic completion list moved to pulsar-ide-magma, which also completes your own intrinsics and functions.

## Known limitations

- Runs of `//` comments separated only by blank lines fold as one run. Tree-sitter treats them as neighbours, and folds can't tell how many rows lie between.
- Continuation lines of a multi-line docstring are free text. **Editor: Auto Indent** sets them to the docstring's level.
- The parser does not yet accept a completely empty loop body (`for i in S do end for;`), so such a line is highlighted as an error. Anything inside the body, even a comment, avoids it.

## Rebuilding the parser

`grammars/tree-sitter/tree-sitter-magma.wasm` is built from the commit named in `grammars/modern-tree-sitter-magma.cson`. To rebuild it, or move to a newer commit:

```sh
scripts/build-parser.sh            # the pinned commit
scripts/build-parser.sh main       # the latest upstream
```

The script needs git and the [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/releases) 0.26 or later (it fetches wasi-sdk itself; no Emscripten or Docker needed).

## Running the specs

```sh
pulsar --test spec
```

## Credits

The TextMate grammar started as an automatic translation of David Howden's Magma TextMate bundle. The Tree-sitter parser is by Edgar Costa and Håvard Damm-Johnsen.
