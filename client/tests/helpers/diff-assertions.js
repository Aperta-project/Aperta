import Ember from 'ember';
import QUnit from 'qunit';

export default function() {
  QUnit.assert.isGreen = function(text) {
    this.ok(addedTextIncludes(text), `New text, ${text}, is green`);
  }

  QUnit.assert.isRed = function(text) {
    this.ok(removedTextIncludes(text), `Old text, ${text}, is red `);
  }

  QUnit.assert.diffPresent = function(oldText, newText) {
    this.elementFound(`.added:contains(${newText})`, 'Has 1 added diff elements');
    this.elementFound(`.removed:contains(${oldText})`, 'Has 1 removed diff elements');
  }

  QUnit.assert.linkDiffPresent = function(options){
    let removed = options.removed,
        added = options.added;

    if (removed) {
      let removedUrl = removed.url,
        removedText = removed.text;
        QUnit.assert.elementFound(
          `a.removed[href='${removedUrl}']:contains(${removedText})`,
          'The removed link was found on the page'
        );
    }

    if (added) {
      let addedUrl = added.url,
        addedText = added.text;
        QUnit.assert.elementFound(
          `a.added[href='${addedUrl}']:contains(${addedText})`,
          'The added link was found on the page'
        );
    }
  }

  QUnit.assert.notDiffed = function(text) {
    this.ok(!addedTextIncludes(text), `New text is not diffed`);
    this.ok(!removedTextIncludes(text), `Old text is not diffed`);
  }

  function addedTextIncludes(text) {
    return Ember.$('.added').text().includes(text);
  }

  function removedTextIncludes(text) {
    return Ember.$('.removed').text().includes(text);
  }
}
