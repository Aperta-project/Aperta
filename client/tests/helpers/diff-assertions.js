/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
