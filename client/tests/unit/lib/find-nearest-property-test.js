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

import Ember from 'ember';
import { module, test } from 'qunit';
import findNearestProperty from 'tahi/lib/find-nearest-property';

module('FindNearestProperty');

let scenario = Ember.Object.create({isEditable: true});

function createScenario(scenario, level=1) {
  var parent = Ember.Object.create(scenario);
  for (var i = 1; i < level; i++) {
    parent = Ember.Object.create({parent: parent});
  }
  return parent;
}

test('immediate success', function(assert) {
  let parent = createScenario({scenario: scenario});
  let result = findNearestProperty(parent, 'scenario');
  assert.equal(result && result.isEditable, true, 'scenario on immediate object is found');
});

test('nested success', function(assert) {
  let parent = createScenario({scenario: scenario}, 3);
  let result = findNearestProperty(parent, 'scenario', 'parent');
  assert.equal(result && result.isEditable, true, 'scenario on nested object is found');
});

test('immediate failure', function(assert) {
  let parent = createScenario({nonScenario: scenario});
  let result = findNearestProperty(parent, 'scenario', 'parent');
  assert.equal(result, null, 'scenario on immediate object not found');
});

test('nested failure', function(assert) {
  let parent = createScenario({nonScenario: scenario}, 3);
  let result = findNearestProperty(parent, 'scenario', 'parent');
  assert.equal(result, null, 'scenario on nested object not found');
});
