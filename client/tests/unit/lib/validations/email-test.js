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
import { validation } from 'tahi/lib/validations/email';

module('validations/email');

test('null', function(assert) {
  const value = null;
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('missing @', function(assert) {
  const value = 'testexample.com';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('missing .', function(assert) {
  const value = 'test@examplecom';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('valid addresses', function(assert) {
  assert.equal(validation('t@example.com'), true, 'validation 1 passed');
  assert.equal(validation('t+2@example.com'), true, 'validation 1 passed');
  assert.equal(validation('t_3@example-test.io'), true, 'validation 1 passed');
});
