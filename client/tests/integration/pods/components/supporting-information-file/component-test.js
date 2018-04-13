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
import { manualSetup, make } from 'ember-data-factory-guy';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import customAssertions from 'tahi/tests/helpers/custom-assertions';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent(
  'supporting-information-file',
  'Integration | Component | supporting information file',
  {
    integration: true,
    beforeEach() {
      initTruthHelpers();
      customAssertions();
      manualSetup(this.container);
    }
  });

test('user can edit an existing file and then cancel', function(assert) {

  this.set('fileProxy', Ember.Object.create({
    object: make('supporting-information-file', {label: 'F4', category: 'Figure', status: 'done'})
  }));

  const template = hbs`{{supporting-information-file isEditable=true model=fileProxy}}`;

  this.render(template);

  this.$('.si-file-edit-icon').click();
  this.$('.si-file-label-input').html('S1').keyup();
  this.$('.si-file-cancel-edit-button').click();

  assert.textPresent('.si-file-title', 'F4 Figure', 'label gets reverted on cancel');

});

test('does not validate original attributes on cancel', function(assert) {

  this.set('fileProxy', Ember.Object.create({
    object: make('supporting-information-file', {label: 'F4', category: 'Figure', status: 'done'}),
    validateAll() {
      assert.ok(false, 'validateAll should not be called');
    },
    validationErrorsPresent() {
      return false;
    }
  }));

  let template = hbs`{{supporting-information-file isEditable=true model=fileProxy}}`;

  this.render(template);

  this.$('.si-file-edit-icon').click();
  this.$('.si-file-label-input').html('S1').keyup();
  this.$('.si-file-cancel-edit-button').click();
  assert.textPresent('.si-file-title', 'F4 Figure', 'label gets reverted on cancel');

});

test('validates attributes and updates the file on save', function(assert) {
  assert.expect(3);
  this.set('fileProxy', Ember.Object.create({
    object: make('supporting-information-file', {title: 'Old Title', category: 'Figure', status: 'done'}),
    validateAll() {
      assert.ok(true, 'validateAll is called');
    },
    validationErrorsPresent() {
      return false;
    }
  }));

  this.set('updateStub', function() { assert.ok(true, 'update action is called'); });
  this.set('resetStub', function() { assert.ok(true, 'reset action is called'); });

  const template = hbs`{{supporting-information-file
                       isEditable=true
                       model=fileProxy
                       resetSIErrorsForFile=(action resetStub)
                       updateFile=(action updateStub)}}`;

  this.render(template);

  this.$('.si-file-edit-icon').click();
  this.$('.si-file-save-edit-button').click();
});
