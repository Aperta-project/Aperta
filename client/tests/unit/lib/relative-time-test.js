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
import relativeTime from 'tahi/lib/relative-time';

module('RelativeTime');

let now = 'September 13, 2016 13:17:56 UTC';

test('1 day ago, beginning of day', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('September 12, 2016 00:00:09 UTC');

  assert.equal(relativeTime(date, startOfDay), '1 day ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '1 day ago', 'returns a human readable string for how many days ago a date was');
});

test('3 days ago, beginning of day', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('September 10, 2016 00:00:09 UTC');

  assert.equal(relativeTime(date, startOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
});

test('3 days ago, noon time', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('September 10, 2016 12:00:00 UTC');

  assert.equal(relativeTime(date, startOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
});

test('3 days ago, end of day', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('September 10, 2016 23:59:59 UTC');

  assert.equal(relativeTime(date, startOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
});

test('61 days ago, beginning of day', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('July 14, 2016 00:00:09 UTC');

  assert.equal(relativeTime(date, startOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
});

test('61 days ago, noon time', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('July 14, 2016 12:00:00 UTC');

  assert.equal(relativeTime(date, startOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
});

test('61 days ago, end of day', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('July 14, 2016 23:59:59 UTC');

  assert.equal(relativeTime(date, startOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
});
