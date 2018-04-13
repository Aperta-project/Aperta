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

import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';


moduleForComponent('paper-preview-error-message', 'Integration | Component | paper-preview-error-message', {
  integration: true,
  beforeEach() {
    this.set('toggle', function(){});
    this.set('feedback', function(){});
  }
});

let template = hbs`{{paper-preview-error-message paper=paper toggle=toggle feedback=feedback}}`;

test('paper is submitted without errors but cannot be rendered', function(assert) {
  this.set('paper', {
    'isSubmitted': true
  });
  this.render(template);
  assert.textPresent('p', `This may be due to images, audio, video, or other
    objects embedded in the original manuscript file.
    You can download the manuscript to
    your computer to view it.
    If you would like to contact us, you can reach us via our
    Feedback form.`, 'paper is submitted but cannot be rendered');
});

test('paper is not submitted and preview fails', function(assert) {
  this.set('paper', {
    'isSubmitted': false,
    'previewFail': true
  });
  this.render(template);
  assert.textPresent('p', `If you are using an unsupported browser, please try a different web browser, or you can download the manuscript to your computer to view it.`, 'paper is not submitted and preview fails (unsupported browser)');
});

test('paper is not submitted, preview did not fail but paper could not be rendered', function(assert) {
  this.set('paper', {
    'isSubmitted': false,
    'previewFail': false
  });
  this.render(template);
  assert.textPresent('h3', 'Your file was uploaded successfully, but we were unable to render a preview at this time.', 'paper is not submitted, preview did not fail but rendered failed (description)');
});
