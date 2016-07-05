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
    this.equal(Ember.$('.added').length, 1, 'Has 1 added diff elements');
    this.equal(Ember.$('.removed').length, 1, 'Has 1 removed diff elements');
    this.isGreen(newText);
    this.isRed(oldText);
  }

  QUnit.assert.linkDiffPresent = function(options){
    let removedUrl = options.removed.url,
      removedText = options.removed.text,
      addedUrl = options.added.url,
      addedText = options.added.text;

    QUnit.assert.elementFound(
      `a.removed[href='${removedUrl}']:contains(${removedText})`,
      'The removed link was found on the page'
    );
    QUnit.assert.elementFound(
      `a.added[href='${addedUrl}']:contains(${addedText})`,
      'The added link was found on the page'
    );
  },

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
