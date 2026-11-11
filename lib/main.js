'use strict';
// Highlighting that other Pulsar packages add inside Magma comments and
// strings. Pulsar's bundled `language-todo` colours words like TODO, NOTE,
// FIXME and BUG, and `language-hyperlink` underlines URLs, but only in the
// places a grammar points them to. These two functions are those pointers.

module.exports = {
  consumeTodoInjection(todo) {
    // Line and block comments, and intrinsic docstrings.
    todo.addInjectionPoint('source.magma', { types: ['comment', 'doc_string'] });
  },

  consumeHyperlinkInjection(hyperlink) {
    hyperlink.addInjectionPoint('source.magma', { types: ['comment', 'doc_string', 'string'] });
  },
};
