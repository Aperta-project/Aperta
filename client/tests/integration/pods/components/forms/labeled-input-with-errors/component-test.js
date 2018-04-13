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

moduleForComponent('forms/labeled-input-with-errors',
  'Integration | Component | forms | labeled input with errors', {
    integration: true
  }
);

test('it renders a label', function(assert) {
  this.render(hbs`{{forms/labeled-input-with-errors label='Fred'}}`);

  assert.textPresent('label', 'Fred');
});

test('it renders a text input', function(assert) {
  this.render(hbs`{{forms/labeled-input-with-errors type='text' label='Fred'}}`);
  assert.elementFound('.form-control[type="text"]');
});

test('it renders a textarea input', function(assert) {
  this.render(hbs`{{forms/labeled-input-with-errors type='textarea' label='Fred'}}`);
  assert.elementFound('textarea.form-control');
});

test('it shows normal input if no errors', function(assert) {
  this.set('errors', null);
  this.render(hbs`{{forms/labeled-input-with-errors label="Fred" errors=errors}}`);

  assert.elementNotFound('.labeled-input-with-errors-errored');
});

test('if shows no errors if error exists on a different field', function(assert) {
  const errors = new DS.Errors;
  errors.add('different-field', 'error on different field');

  this.set('errors', errors);
  this.render(hbs`{{forms/labeled-input-with-errors type='text' name='first-name-field' label='Fred' errors=errors}}`);
  assert.elementNotFound('.labeled-input-with-errors-errored');
});

test('it shows error message on field if it has an error', function(assert) {
  let errors = new DS.Errors;
  errors.add('first-name-field', 'Fill it out');

  this.set('errors', errors);
  this.render(hbs`{{forms/labeled-input-with-errors type='text' name='first-name-field' label='Fred' errors=errors}}`);
  assert.textPresent('.error-message', 'Fill it out');
});

test('it shows multiple error message on field if it has an error', function(assert) {
  let errors = new DS.Errors;
  errors.add('first-name-field', 'Fill it out');
  errors.add('first-name-field', 'Make it look nice');

  this.set('errors', errors);
  this.render(hbs`{{forms/labeled-input-with-errors type='text' name='first-name-field' label='Fred' errors=errors}}`);
  assert.textPresent('.error-message', 'Fill it out');
  assert.textPresent('.error-message', 'Make it look nice');
});

test('it shows styled input if errors', function(assert) {
  const errors = new DS.Errors;
  errors.add('first-name-field', 'Fill it out');

  this.set('errors', errors);
  this.render(hbs`{{forms/labeled-input-with-errors type='text' name='first-name-field' label='Fred' errors=errors}}`);
  assert.elementFound('.labeled-input-with-errors-errored');
});

test('it adds the dasherized name to the input and label classes', function(assert) {
  this.render(hbs`{{forms/labeled-input-with-errors name='funTimes' type='text' label='Fred'}}`);
  assert.elementFound('label.fun-times');
  assert.elementFound('.fun-times[type="text"]');
});

test('it adds the required class if the required prop is passed in', function(assert) {
  this.render(hbs`{{forms/labeled-input-with-errors name='funTimes' type='text' label='Fred' required=true}}`);
  assert.elementFound('label.required');
});
