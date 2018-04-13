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

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('file-label', 'Integration | Component | file label', {
  integration: true,

  beforeEach() {
    this.set('docxFileName', 'test.docx');
    this.set('docFileName', 'test.doc');
    this.set('pdfFileName', 'test.pdf');
    this.set('zipFileName', 'test.zip');
    this.set('texFileName', 'test.tex');
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{file-label fileName=docxFileName}}
  `);

  assert.equal(this.$('.file-label').length, 1);
});

test('it shows PDF correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=pdfFileName}}
  `);

  assert.textPresent('.file-label', 'PDF');
  assert.elementFound('.fa-file-pdf-o', 'The pdf icon appears');
});

test('it shows DOC correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=docFileName}}
  `);

  assert.textPresent('.file-label', 'Word');
  assert.elementFound('.fa-file-word-o', 'The word doc icon appears');
});

test('it shows DOCX correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=docxFileName}}
  `);

  assert.textPresent('.file-label', 'Word');
  assert.elementFound('.fa-file-word-o', 'The word doc icon appears');
});

test('it shows ZIP correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=zipFileName}}
  `);

  assert.textPresent('.file-label', 'Zip');
  assert.elementFound('.fa-file-archive-o', 'The archive icon appears');
});

test('it shows LaTeX correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=texFileName}}
  `);

  assert.textPresent('.file-label', 'LaTeX');
  assert.elementFound('.fa-file-text-o', 'The text icon appears');
});
