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

import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';

moduleForComponent(
  'card-content/tabbed-textarea',
  'Integration | Component | card content | tabbed textarea',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('actionStub', function() {});
    }
  }
);

let annotationTemplate = hbs`{{card-content/tabbed-textarea
          annotationChanged=(action actionStub)
          showAnnotation=true
          annotation='annotation test'}}`;

test(`it can render annotation text alone`, function(assert) {
  this.render(annotationTemplate);
  assert.equal(this.$('.annotation-text textarea.tabbed-textarea').val(), 'annotation test');
  assert.elementNotFound('.instruction-text');
});

let instructionTemplate = hbs`{{card-content/tabbed-textarea
          annotationChanged=(action actionStub)
          showAnnotation=false
          instructionText='instruction test'}}`;

test(`it can render instruction text alone`, function(assert) {
  this.render(instructionTemplate);
  assert.equal(this.$('.instruction-text textarea.tabbed-textarea').val(), 'instruction test');
  assert.elementNotFound('.annotation-text');
});

let combinedTemplate = hbs`{{card-content/tabbed-textarea
          annotationChanged=(action actionStub)
          showAnnotation=true
          annotation='annotation test'
          instructionText='instruction test'}}`;

test(`it can render cobined text together`, function(assert) {
  this.render(combinedTemplate);
  assert.equal(this.$('.annotation-text textarea.tabbed-textarea').val(), 'annotation test');
  assert.equal(this.$('.instruction-text textarea.tabbed-textarea').val(), 'instruction test');
});

test(`it sends 'annotationChanged' on input`, function(assert) {
  assert.expect(1);
  this.set('actionStub', function(e) {
    assert.equal(e.target.value, 'changed value');
  });
  this.render(annotationTemplate);
  this.$('textarea.tabbed-textarea').val('changed value').trigger('input');
});
