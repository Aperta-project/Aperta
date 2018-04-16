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

import { module, test } from 'qunit';
import validator from 'tahi/lib/validator';

module('validator');

test('one validation, no options, no errors', function(assert) {
  const key   = 'key';
  const value = 'test';
  const validations = ['presence'];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 0, 'No error messages');
});

test('one validation, no options, one error', function(assert) {
  const key   = 'key';
  const value = null;
  const validations = ['presence'];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 1, 'One error message');
});

test('two validations, no options, one error', function(assert) {
  const key   = 'key';
  const value = 'two';
  const validations = ['presence', 'number'];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 1, 'One error message');
});

test('two validations, no options, two errors', function(assert) {
  const key   = 'key';
  const value = null;
  const validations = ['number', 'presence'];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 2, 'Two error messages');
});

test('one validation, options, no errors', function(assert) {
  const key   = 'key';
  const value = null;
  const validations = [{type: 'number', allowBlank: true}];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 0, 'No error messages');
});

test('one validation, options with skipCheck true, no errors', function(assert) {
  const key   = 'key';
  const value = 'string';
  const validations = [{
    type: 'number',
    skipCheck: function() { return true; }
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 0, 'No error messages');
});

test('one validation, options with skipCheck false, errors', function(assert) {
  const key   = 'key';
  const value = 'string';
  const validations = [{
    type: 'number',
    skipCheck: function() { return false; }
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 1, 'Error message');
});

test('one validation, options with custom message', function(assert) {
  const customMessage = 'fix it';
  const key   = 'key';
  const value = null;
  const validations = [{
    type: 'presence',
    message: customMessage
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages[0], customMessage, 'Custom message');
});

test('one validation, options with custom message function', function(assert) {
  const customMessage = 'fix me';
  const key   = 'key';
  const value = null;
  const validations = [{
    type: 'presence',
    message() {
      return customMessage;
    }
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages[0], customMessage, 'Custom message function');
});

test('options with custom validation, errors', function(assert) {
  const key = 'key';
  const value = null;
  const validations = [{
    type: 'presence',
    validation: function() { return false; }
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 1, 'custom function found errors');
});

test('options with custom validation, no errors', function(assert) {
  const key = 'key';
  const value = null;
  const validations = [{
    type: 'presence',
    validation: function() { return true; }
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 0, 'custom function found no errors');
});
