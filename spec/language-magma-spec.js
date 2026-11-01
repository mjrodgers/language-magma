// Run with Pulsar's built-in runner: `pulsar --test spec` from the package
// folder, or "Window: Run Package Specs" with this package open.
const path = require('path');
const fs = require('fs');

const fixture = (name) => path.join(__dirname, 'fixtures', name);

// Load a fixture into a new editor with the Magma grammar. (Reading the text
// ourselves keeps the specs independent of file watching.)
async function openFixture(name, { tabLength = 4 } = {}) {
  const editor = await atom.workspace.open();
  editor.setSoftTabs(true);
  editor.setTabLength(tabLength);
  editor.setGrammar(atom.grammars.grammarForScopeName('source.magma'));
  const languageMode = editor.getBuffer().getLanguageMode();
  await languageMode.ready;
  editor.setText(fs.readFileSync(fixture(name), 'utf8'));
  await languageMode.atTransactionEnd();
  return editor;
}

function scopesAt(editor, row, column) {
  return editor.scopeDescriptorForBufferPosition([row, column]).getScopesArray();
}

// Find the first occurrence of `needle` on the row containing `lineMarker`.
function positionOf(editor, lineMarker, needle) {
  const lines = editor.getText().split('\n');
  const row = lines.findIndex((l) => l.includes(lineMarker));
  if (row < 0) throw new Error(`No row containing ${lineMarker}`);
  const column = lines[row].indexOf(needle ?? lineMarker);
  return [row, column];
}

describe('language-magma', () => {
  beforeEach(async () => {
    atom.config.set('core.useTreeSitterParsers', true);
    await atom.packages.activatePackage('language-magma');
  });

  describe('grammars', () => {
    it('registers a modern Tree-sitter grammar for source.magma', () => {
      const grammar = atom.grammars.grammarForScopeName('source.magma');
      expect(grammar).toBeTruthy();
      expect(grammar.name).toBe('Magma');
    });

    it('chooses Magma for .m files that look like Magma', () => {
      const text = fs.readFileSync(fixture('highlighting.m'), 'utf8');
      const grammar = atom.grammars.selectGrammar(fixture('highlighting.m'), text);
      expect(grammar.scopeName).toBe('source.magma');
      expect(grammar.type).toBe('modern-tree-sitter');
    });

    it('uses the Tree-sitter language mode', async () => {
      const editor = await openFixture('highlighting.m');
      expect(editor.getBuffer().getLanguageMode().constructor.name)
        .toBe('WASMTreeSitterLanguageMode');
    });
  });

  describe('highlighting', () => {
    let editor;
    beforeEach(async () => { editor = await openFixture('highlighting.m'); });

    const cases = [
      ['intrinsic Order2', 'intrinsic', 'storage.type.function.intrinsic.magma'],
      ['intrinsic Order2', 'Order2', 'entity.name.function.intrinsic.magma'],
      ['intrinsic Order2', 'G', 'variable.parameter.magma'],
      ['intrinsic Order2', 'GrpPerm', 'support.type.magma'],
      ['intrinsic Order2', 'Strict', 'variable.parameter.optional.magma'],
      ['{Returns', '{Returns', 'comment.block.documentation.magma'],
      ['square :=', 'square', 'entity.name.function.magma'],
      ['square :=', 'function', 'storage.type.function.magma'],
      ['// line comment', '//', 'comment.line.double-slash.magma'],
      ['/* block', '/*', 'comment.block.magma'],
      ['if IsEven', 'if', 'keyword.control.conditional.magma'],
      ['if IsEven', 'IsEven', 'support.other.function.magma'],
      ['for i in', 'for', 'keyword.control.repeat.magma'],
      ['for i in', 'in', 'keyword.operator.word.magma'],
      ['s := "hello', '"hello', 'string.quoted.double.magma'],
      ['n := 42', '42', 'constant.numeric.integer.magma'],
      ['r := 1.5', '1.5', 'constant.numeric.float.magma'],
      ['b := true', 'true', 'constant.language.boolean.true.magma'],
      ['H := sub<', 'sub', 'support.function.constructor.magma'],
      ['R<x> :=', 'x', 'variable.other.generator.magma'],
      ['G`Order', 'Order', 'variable.other.attribute.magma'],
      ['load "', 'load', 'keyword.control.import.magma'],
      ['print n', 'print', 'keyword.other.print.magma'],
      ['n +:=', '+:=', 'keyword.operator.assignment.magma'],
      ['declare verbose', 'MyFlag', 'constant.other.verbose-flag.magma'],
      ['try', 'try', 'keyword.control.exception.magma'],
    ];

    for (const [line, token, scope] of cases) {
      it(`scopes ${token} on "${line}" as ${scope}`, () => {
        const [row, column] = positionOf(editor, line, token);
        expect(scopesAt(editor, row, column)).toContain(scope);
      });
    }
  });

  describe('indentation', () => {
    for (const [name, tabLength] of [['indentation.m', 4], ['indentation-2.m', 2]]) {
      it(`re-indents ${name} back to its original layout`, async () => {
        const original = fs.readFileSync(fixture(name), 'utf8');
        const editor = await openFixture(name, { tabLength });
        const languageMode = editor.getBuffer().getLanguageMode();
        editor.setText(original.split('\n').map((l) => l.trimStart()).join('\n'));
        await languageMode.atTransactionEnd();
        editor.selectAll();
        editor.autoIndentSelectedRows();
        const expected = original.split('\n');
        const actual = editor.getText().split('\n');
        for (let row = 0; row < expected.length; row++) {
          // Continuation lines of multi-line docstrings are free text.
          if (/^\s+\S.*\}$/.test(expected[row]) && !/[;{]/.test(expected[row])) continue;
          expect(`${row + 1}: ${actual[row]}`).toBe(`${row + 1}: ${expected[row]}`);
        }
      });
    }

    it('dedents `end` to match the opening keyword while typing', async () => {
      // The spec environment turns auto-indent off by default.
      atom.config.set('editor.autoIndent', true);
      const editor = await atom.workspace.open();
      editor.setGrammar(atom.grammars.grammarForScopeName('source.magma'));
      editor.setSoftTabs(true);
      editor.setTabLength(4);
      const languageMode = editor.getBuffer().getLanguageMode();
      await languageMode.ready;
      // Type the way a person does: one character at a time, Enter between rows.
      const type = async (text) => {
        for (const ch of text) {
          editor.insertText(ch, { autoIndent: true, autoDecreaseIndent: true });
          await languageMode.atTransactionEnd();
        }
      };
      const enter = async () => {
        editor.getLastSelection().insertText('\n', { autoIndent: true, autoIndentNewline: true });
        await languageMode.atTransactionEnd();
      };
      await type('for i in [1..3] do');
      await enter();
      expect(editor.lineTextForBufferRow(1)).toBe('    ');
      await type('if IsOdd(i) then');
      await enter();
      expect(editor.lineTextForBufferRow(2)).toBe('        ');
      await type('print i;');
      await enter();
      await type('end if;');
      expect(editor.lineTextForBufferRow(3)).toBe('    end if;');
      await enter();
      await type('end for;');
      expect(editor.lineTextForBufferRow(4)).toBe('end for;');
    });

    for (const [name, tabLength] of [['indentation.m', 4], ['indentation-2.m', 2]]) {
      it(`produces the layout of ${name} when it is typed from scratch`, async () => {
        atom.config.set('editor.autoIndent', true);
        const expected = fs.readFileSync(fixture(name), 'utf8').split('\n');
        const editor = await atom.workspace.open();
        editor.setSoftTabs(true);
        editor.setTabLength(tabLength);
        editor.setGrammar(atom.grammars.grammarForScopeName('source.magma'));
        const languageMode = editor.getBuffer().getLanguageMode();
        await languageMode.ready;
        for (let row = 0; row < expected.length; row++) {
          if (row > 0) {
            editor.getLastSelection().insertText('\n', { autoIndent: true, autoIndentNewline: true });
            await languageMode.atTransactionEnd();
          }
          for (const ch of expected[row].trim()) {
            editor.insertText(ch, { autoIndent: true, autoDecreaseIndent: true });
            await languageMode.atTransactionEnd();
          }
        }
        const actual = editor.getText().split('\n');
        for (let row = 0; row < expected.length; row++) {
          if (!expected[row].trim()) continue;
          // Continuation lines of multi-line docstrings are free text.
          if (/^\s+\S.*\}$/.test(expected[row]) && !/[;{]/.test(expected[row])) continue;
          expect(`${row + 1}: ${actual[row]}`).toBe(`${row + 1}: ${expected[row]}`);
        }
      });
    }
  });

  describe('folding', () => {
    it('folds definitions and blocks, keeping `end` visible', async () => {
      const editor = await openFixture('indentation.m');
      const rowOf = (text) => editor.getText().split('\n').findIndex((l) => l.startsWith(text));
      for (const start of ['intrinsic DoubleCoset', 'square :=', 'procedure Bump', 'while i lt 10', 'repeat', 'try']) {
        const row = rowOf(start);
        expect(`${start}: ${editor.isFoldableAtBufferRow(row)}`).toBe(`${start}: true`);
      }
      const row = rowOf('square :=');
      editor.foldBufferRow(row);
      // The `end function;` row stays visible below the fold.
      expect(editor.isFoldedAtBufferRow(row + 1)).toBe(true);
      expect(editor.isFoldedAtBufferRow(row + 2)).toBe(false);
    });
  });
});
