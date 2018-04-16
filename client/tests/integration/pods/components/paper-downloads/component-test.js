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
import { manualSetup, make } from 'ember-data-factory-guy';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('paper-downloads', 'Integration | Component | Paper Downloads', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);

    const docxPaper = make('paper', {
      versionedTexts: [{
        id: 1,
        isDraft: false,
        majorVersion: 1,
        minorVersion: 1,
        updatedAt: '2017-01-30T22:51:16.000Z',
        fileType: 'docx'
      }]
    });
    this.set('docxPaper', docxPaper);

    const pdfPaper = make('paper', {
      versionedTexts: [{
        id: 2,
        isDraft: false,
        majorVersion: 1,
        minorVersion: 1,
        updatedAt: '2017-01-30T22:51:16.000Z',
        fileType: 'pdf'
      }]
    });
    this.set('pdfPaper', pdfPaper);

    const pdfAndSourcePaper = make('paper', {
      versionedTexts: [{
        id: 3,
        isDraft: false,
        majorVersion: 1,
        minorVersion: 1,
        updatedAt: '2017-01-30T22:51:16.000Z',
        fileType: 'pdf',
        sourceType: 'docx'
      }]
    });
    this.set('pdfAndSourcePaper', pdfAndSourcePaper);
    this.set('toggle', function(){});
  }
});

let template = hbs`
    {{paper-downloads paper=docxPaper toggle=toggle}}`;


test('it renders', function(assert) {
  assert.expect(1);

  this.render(template);

  assert.equal(this.$('.paper-downloads').length, 1);
});


test('docx versions display download links', function(assert) {
  this.render(template);

  assert.equal(this.$('.download-docx').length, 1);
  assert.equal(this.$('.download-pdf').length, 1);
});

test('it displays version number and date completed', function(assert) {
  this.render(template);

  assert.ok(this.$('td.paper-downloads-version').text(), 'v1.1 - Jan 30, 2017');
});
