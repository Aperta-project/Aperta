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
import stripHtml from 'tahi/lib/strip-html';

module('StripHtml');

test('strips html - simple case', function(assert) {
  let result = stripHtml('<p>Testing</p>');
  assert.equal(result, 'Testing', 'strips HTML');
});

test('strips html - complex case', function(assert) {
  let result = stripHtml('<p><b>Testing</b> a more <i>complex case</i> is smart</p>');
  assert.equal(result, 'Testing a more complex case is smart', 'strips HTML');
});

test('returns empty string when given undefined value', function(assert) {
  let result = stripHtml(undefined);
  assert.equal(result, '', 'empty string when given undefined');
});

test('returns empty string when given null value', function(assert) {
  let result = stripHtml(null);
  assert.equal(result, '', 'empty string when given null');
});
