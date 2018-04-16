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
import { validation } from 'tahi/lib/validations/number';

module('validations/number');

test('string with letters', function(assert) {
  const value = 'test';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('string with number', function(assert) {
  const value = '100';
  const pass = validation(value);

  assert.equal(pass, true, 'validation pass');
});

test('string with numbers and letters', function(assert) {
  const value = '100x';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('integer with zero', function(assert) {
  const value = 0;
  const pass = validation(value);

  assert.equal(pass, true, 'validation passed');
});

test('float', function(assert) {
  const value = 10.01;
  const pass = validation(value);

  assert.equal(pass, true, 'validation passed');
});

test('blank value, allow blank', function(assert) {
  const value = null;
  const options = { allowBlank: true };
  const pass = validation(value, options);

  assert.equal(pass, true, 'validation passed');
});

test('null', function(assert) {
  const value = null;
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('undefined', function(assert) {
  const pass = validation();

  assert.equal(pass, false, 'validation failed');
});

test('blank string', function(assert) {
  const value = '';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});
