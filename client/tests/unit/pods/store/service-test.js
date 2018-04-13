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

import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';

moduleFor('service:store', 'Unit | Service | store', {
  integration: true
});

/*
 * peekTask is the public face of a few helper methods we use that depend on the internal
 * implementation of the store.
*/
test('peekTask finds any type of task in the store with the given id', function(assert) {
  let store = this.subject();
  Ember.run(() => {
    let t1 =    store.createRecord('ad-hoc-task', {id: '1'});
    let t2 =  store.createRecord('reviewer-report-task', {id: '2'});
    assert.equal(store.peekTask('1'), t1);
    assert.equal(store.peekTask('2'), t2);
  });
});
