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

import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';
import { module, test } from 'qunit';

module('Unit: de-namespace-task-type');

test('deNamespaceTaskType denamespaces task types', function(assert) {
  var result;
  result = deNamespaceTaskType('Foo::BarTask');
  return assert.equal(result, 'BarTask', 'strips the namespace off the type');
});

test('deNamespaceTaskType doesnt touch unnamespaced stuff', function(assert) {
  var result;
  result = deNamespaceTaskType('Task');
  return assert.equal(result, 'Task', 'Task goes through unchanged');
});

test('deNamespaceTaskType denamespaces deeply namespaced task types', function(assert) {
  var result;
  result = deNamespaceTaskType('Foo::Baz::BarTask');
  return assert.equal(result, 'BarTask', 'strips the namespace off the type');
});

test('deNamespaceTaskType denamespaces really deeply namespaced task types', function(assert) {
  var result;
  result = deNamespaceTaskType('Tahi::Foo::Baz::BarTask');
  return assert.equal(result, 'BarTask', 'strips the namespace off the type');
});
