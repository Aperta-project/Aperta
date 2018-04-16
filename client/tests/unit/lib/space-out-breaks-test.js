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
import spacesOutBreaks from 'tahi/lib/space-out-breaks';

module('SpaceOutBreaks');

test('spaces out breaks - simple case', function(assert) {
  let result = spacesOutBreaks('<p>Test<br>ing</p>');
  assert.equal(result, '<p>Test ing</p>', 'spaces out breaks');
});

test('spaces out breaks - complex case', function(assert) {
  let result = spacesOutBreaks('<p><b>Testing</b>  <br> a more <i><br>complex case</i> <br>is smart</p>');
  assert.equal(result, '<p><b>Testing</b> a more <i>complex case</i> is smart</p>', 'spaces out breaks');
});

test('returns empty string when given undefined value', function(assert) {
  let result = spacesOutBreaks(undefined);
  assert.equal(result, '', 'empty string when given undefined');
});

test('returns empty string when given null value', function(assert) {
  let result = spacesOutBreaks(null);
  assert.equal(result, '', 'empty string when given null');
});

test('properly notices hanging brackets', (assert) => {
  let result = spacesOutBreaks(`<p>some are < than<br> some but <br>> than others</p>`);
  assert.equal(result, '<p>some are < than some but > than others</p>');
});
