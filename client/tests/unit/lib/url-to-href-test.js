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
import urlToHref from 'tahi/lib/url-to-href';

module('UrlToHref');

test('string with http to anchor tags', function(assert) {
  let text           = 'http://tahi.com';
  let result         = urlToHref(text);
  let expectedResult = '<a href="http://tahi.com">http://tahi.com</a>';

  assert.equal(result, expectedResult, 'returns string with anchor tags: ' + expectedResult);
});

test('string with www to anchor tags', function(assert) {
  let text           = 'www.tahi.com';
  let result         = urlToHref(text);
  let expectedResult = '<a href="http://www.tahi.com">www.tahi.com</a>';

  assert.equal(result, expectedResult, 'returns string with anchor tags with www: ' + expectedResult);
});

test('string with anchor to open in new window', function(assert) {
  let text           = 'http://tahi.com';
  let result         = urlToHref(text, true);
  let expectedResult = '<a href="http://tahi.com" target="_blank">http://tahi.com</a>';

  assert.equal(result, expectedResult, 'returns string to open in new window: ' + expectedResult);
});

test('string with with multiple links', function(assert) {
  let text           = 'My favorite site: http://tahi.com. Also, www.tahi-project.org';
  let result         = urlToHref(text);
  let expectedResult = 'My favorite site: <a href="http://tahi.com">http://tahi.com</a>. Also, <a href="http://www.tahi-project.org">www.tahi-project.org</a>';

  assert.equal(result, expectedResult, 'returns string with multiple anchor tags: ' + expectedResult);
});
