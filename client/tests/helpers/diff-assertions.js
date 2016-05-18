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
    this.equal(Ember.$('.added').length, 1, 'Has 1 added diff spans');
    this.equal(Ember.$('.removed').length, 1, 'Has 1 removed diff spans');
    this.isGreen(newText);
    this.isRed(oldText);
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
